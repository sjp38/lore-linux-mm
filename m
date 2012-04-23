Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 1EC2F6B0044
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 15:08:22 -0400 (EDT)
Received: by dadq36 with SMTP id q36so17978219dad.8
        for <linux-mm@kvack.org>; Mon, 23 Apr 2012 12:08:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1335207012-25133-1-git-send-email-sasikanth.v19@gmail.com>
References: <1335207012-25133-1-git-send-email-sasikanth.v19@gmail.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Mon, 23 Apr 2012 15:08:01 -0400
Message-ID: <CAHGf_=rKK_s=cMTKcaAsyjVgKCoBHPyPfBdHaGo_FiigCMezRg@mail.gmail.com>
Subject: Re: [PATCH] mm:vmstat - Removed debug fs entries on failure of file
 creation and made extfrag_debug_root dentry local
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasikanth V <sasikanth.v19@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Apr 23, 2012 at 2:50 PM, Sasikanth V <sasikanth.v19@gmail.com> wrot=
e:
> Removed debug fs files and directory on failure. Since no one using "extf=
rag_debug_root" dentry outside of function
> extfrag_debug_init made it local to the function.
>
> Signed-off-by: Sasikanth V <sasikanth.v19@gmail.com>
> ---
> =A0mm/vmstat.c | =A0 11 ++++++++---
> =A01 files changed, 8 insertions(+), 3 deletions(-)
>
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index f600557..ddae476 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1220,7 +1220,6 @@ module_init(setup_vmstat)
> =A0#if defined(CONFIG_DEBUG_FS) && defined(CONFIG_COMPACTION)
> =A0#include <linux/debugfs.h>
>
> -static struct dentry *extfrag_debug_root;
>
> =A0/*
> =A0* Return an index indicating how much of the available free memory is
> @@ -1358,17 +1357,23 @@ static const struct file_operations extfrag_file_=
ops =3D {
>
> =A0static int __init extfrag_debug_init(void)
> =A0{
> + =A0 =A0 =A0 struct dentry *extfrag_debug_root;
> +
> =A0 =A0 =A0 =A0extfrag_debug_root =3D debugfs_create_dir("extfrag", NULL)=
;
> =A0 =A0 =A0 =A0if (!extfrag_debug_root)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOMEM;
>
> =A0 =A0 =A0 =A0if (!debugfs_create_file("unusable_index", 0444,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 extfrag_debug_root, NULL, &=
unusable_file_ops))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 extfrag_debug_root, NULL, &=
unusable_file_ops)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 debugfs_remove (extfrag_debug_root);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOMEM;
> + =A0 =A0 =A0 }
>
> =A0 =A0 =A0 =A0if (!debugfs_create_file("extfrag_index", 0444,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 extfrag_debug_root, NULL, &=
extfrag_file_ops))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 extfrag_debug_root, NULL, &=
extfrag_file_ops)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 debugfs_remove_recursive (extfrag_debug_roo=
t);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOMEM;
> + =A0 =A0 =A0 }

Looks good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
