Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 51A086B006C
	for <linux-mm@kvack.org>; Sat, 13 Oct 2012 23:20:54 -0400 (EDT)
Received: by mail-vc0-f169.google.com with SMTP id fl17so5569058vcb.14
        for <linux-mm@kvack.org>; Sat, 13 Oct 2012 20:20:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1350142693-21954-1-git-send-email-andi@firstfloor.org>
References: <1350142693-21954-1-git-send-email-andi@firstfloor.org>
Date: Sun, 14 Oct 2012 11:20:52 +0800
Message-ID: <CAJd=RBD_yjZ+=MTT8Zj+O4BTOHNd3oCcVFTtqi29znhYqHiJGw@mail.gmail.com>
Subject: Re: [PATCH] MM: Support more pagesizes for MAP_HUGETLB/SHM_HUGETLB v5
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>

Hi Andi,

On Sat, Oct 13, 2012 at 11:38 PM, Andi Kleen <andi@firstfloor.org> wrote:
> v2: Port to new tree. Fix unmount.
> v3: Ported to latest tree.
> v4: Ported to latest tree. Minor changes for review feedback. Updated
> description.
> v5: Remove unnecessary prototypes to fix merge error (Hillf Dalton)

s/Dalton/Danton/

>  struct file *hugetlb_file_setup(const char *name, unsigned long addr,
>                                 size_t size, vm_flags_t acctflag,
> -                               struct user_struct **user, int creat_flags)
> +                               struct user_struct **user,
> +                               int creat_flags, int page_size_log)
>  {
>         int error = -ENOMEM;
>         struct file *file;
> @@ -944,9 +957,14 @@ struct file *hugetlb_file_setup(const char *name, unsigned long addr,
>         struct qstr quick_string;
>         struct hstate *hstate;
>         unsigned long num_pages;
> +       int hstate_idx;
> +
> +       hstate_idx = get_hstate_idx(page_size_log);
> +       if (hstate_idx < 0)
> +               return ERR_PTR(-ENODEV);
>
>         *user = NULL;
> -       if (!hugetlbfs_vfsmount)
> +       if (!hugetlbfs_vfsmount[hstate_idx])

Maybe
	if (IS_ERR(hugetlbfs_vfsmount[hstate_idx]))
since ...

>  static int __init init_hugetlbfs_fs(void)
>  {
> +       struct hstate *h;
>         int error;
> -       struct vfsmount *vfsmount;
> +       int i;
>
>         error = bdi_init(&hugetlbfs_backing_dev_info);
>         if (error)
> @@ -1029,14 +1048,26 @@ static int __init init_hugetlbfs_fs(void)
>         if (error)
>                 goto out;
>
> -       vfsmount = kern_mount(&hugetlbfs_fs_type);
> +       i = 0;
> +       for_each_hstate (h) {
> +               char buf[50];
> +               unsigned ps_kb = 1U << (h->order + PAGE_SHIFT - 10);
>
> -       if (!IS_ERR(vfsmount)) {
> -               hugetlbfs_vfsmount = vfsmount;
> -               return 0;
> -       }
> +               snprintf(buf, sizeof buf, "pagesize=%uK", ps_kb);
> +               hugetlbfs_vfsmount[i] = kern_mount_data(&hugetlbfs_fs_type,
> +                                                       buf);
>
> -       error = PTR_ERR(vfsmount);
> +               if (IS_ERR(hugetlbfs_vfsmount[i])) {
> +                               pr_err(
> +                       "hugetlb: Cannot mount internal hugetlbfs for page size %uK",
> +                              ps_kb);
> +                       error = PTR_ERR(hugetlbfs_vfsmount[i]);

		...	hugetlbfs_vfsmount[i] is not reset.

> +               }
> +               i++;
> +       }
> +       /* Non default hstates are optional */
> +       if (hugetlbfs_vfsmount[default_hstate_idx])

ditto.

BTW, resetting looks simpler?

> +               return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
