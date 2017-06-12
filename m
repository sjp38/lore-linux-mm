Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id E8EED6B0292
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 17:31:51 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id 16so41003001iok.9
        for <linux-mm@kvack.org>; Mon, 12 Jun 2017 14:31:51 -0700 (PDT)
Received: from nm13-vm5.bullet.mail.ne1.yahoo.com (nm13-vm5.bullet.mail.ne1.yahoo.com. [98.138.91.235])
        by mx.google.com with ESMTPS id w66si8250397itf.68.2017.06.12.14.31.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jun 2017 14:31:51 -0700 (PDT)
Subject: Re: [PATCH 05/11] Creation of "check_vmflags" LSM hook
References: <1497286620-15027-1-git-send-email-s.mesoraca16@gmail.com>
 <1497286620-15027-6-git-send-email-s.mesoraca16@gmail.com>
From: Casey Schaufler <casey@schaufler-ca.com>
Message-ID: <1dccd8da-c96f-3947-d90f-a3f3d4f389fd@schaufler-ca.com>
Date: Mon, 12 Jun 2017 14:31:48 -0700
MIME-Version: 1.0
In-Reply-To: <1497286620-15027-6-git-send-email-s.mesoraca16@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Salvatore Mesoraca <s.mesoraca16@gmail.com>, linux-kernel@vger.kernel.org
Cc: linux-security-module@vger.kernel.org, kernel-hardening@lists.openwall.com, Brad Spengler <spender@grsecurity.net>, PaX Team <pageexec@freemail.hu>, Kees Cook <keescook@chromium.org>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, linux-mm@kvack.org

On 6/12/2017 9:56 AM, Salvatore Mesoraca wrote:
> Creation of a new LSM hook to check if a given configuration of vmflags,
> for a new memory allocation request, should be allowed or not.
> It's placed in "do_mmap", "do_brk_flags" and "__install_special_mapping".
>
> Signed-off-by: Salvatore Mesoraca <s.mesoraca16@gmail.com>
> Cc: linux-mm@kvack.org
> ---
>  include/linux/lsm_hooks.h | 6 ++++++
>  include/linux/security.h  | 6 ++++++
>  mm/mmap.c                 | 9 +++++++++
>  security/security.c       | 5 +++++
>  4 files changed, 26 insertions(+)
>
> diff --git a/include/linux/lsm_hooks.h b/include/linux/lsm_hooks.h
> index cc0937e..6934cc5 100644
> --- a/include/linux/lsm_hooks.h
> +++ b/include/linux/lsm_hooks.h
> @@ -483,6 +483,10 @@
>   *	@reqprot contains the protection requested by the application.
>   *	@prot contains the protection that will be applied by the kernel.
>   *	Return 0 if permission is granted.
> + * @check_vmflags:
> + *	Check if the requested @vmflags are allowed.
> + *	@vmflags contains requested the vmflags.
> + *	Return 0 if the operation is allowed to continue.
>   * @file_lock:
>   *	Check permission before performing file locking operations.
>   *	Note: this hook mediates both flock and fcntl style locks.
> @@ -1482,6 +1486,7 @@
>  				unsigned long prot, unsigned long flags);
>  	int (*file_mprotect)(struct vm_area_struct *vma, unsigned long reqprot,
>  				unsigned long prot);
> +	int (*check_vmflags)(vm_flags_t vmflags);
>  	int (*file_lock)(struct file *file, unsigned int cmd);
>  	int (*file_fcntl)(struct file *file, unsigned int cmd,
>  				unsigned long arg);
> @@ -1753,6 +1758,7 @@ struct security_hook_heads {
>  	struct list_head mmap_addr;
>  	struct list_head mmap_file;
>  	struct list_head file_mprotect;
> +	struct list_head check_vmflags;
>  	struct list_head file_lock;
>  	struct list_head file_fcntl;
>  	struct list_head file_set_fowner;
> diff --git a/include/linux/security.h b/include/linux/security.h
> index 19bc364..67e33b6 100644
> --- a/include/linux/security.h
> +++ b/include/linux/security.h
> @@ -302,6 +302,7 @@ int security_mmap_file(struct file *file, unsigned long prot,
>  int security_mmap_addr(unsigned long addr);
>  int security_file_mprotect(struct vm_area_struct *vma, unsigned long reqprot,
>  			   unsigned long prot);
> +int security_check_vmflags(vm_flags_t vmflags);
>  int security_file_lock(struct file *file, unsigned int cmd);
>  int security_file_fcntl(struct file *file, unsigned int cmd, unsigned long arg);
>  void security_file_set_fowner(struct file *file);
> @@ -830,6 +831,11 @@ static inline int security_file_mprotect(struct vm_area_struct *vma,
>  	return 0;
>  }
>  
> +static inline int security_check_vmflags(vm_flags_t vmflags)
> +{
> +	return 0;
> +}
> +
>  static inline int security_file_lock(struct file *file, unsigned int cmd)
>  {
>  	return 0;
> diff --git a/mm/mmap.c b/mm/mmap.c
> index f82741e..e19f04e 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1363,6 +1363,9 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
>  	vm_flags |= calc_vm_prot_bits(prot, pkey) | calc_vm_flag_bits(flags) |
>  			mm->def_flags | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
>  
> +	if (security_check_vmflags(vm_flags))
> +		return -EPERM;
> +

Have the hook return a value and return that rather
than -EPERM. That way a security module can choose an
error that it determines is appropriate. It is possible
that a module might want to deny the access for a reason
other than lack of privilege. 

>  	if (flags & MAP_LOCKED)
>  		if (!can_do_mlock())
>  			return -EPERM;
> @@ -2833,6 +2836,9 @@ static int do_brk_flags(unsigned long addr, unsigned long request, unsigned long
>  		return -EINVAL;
>  	flags |= VM_DATA_DEFAULT_FLAGS | VM_ACCOUNT | mm->def_flags;
>  
> +	if (security_check_vmflags(flags))
> +		return -EPERM;
> +

Same here

>  	error = get_unmapped_area(NULL, addr, len, 0, MAP_FIXED);
>  	if (offset_in_page(error))
>  		return error;
> @@ -3208,6 +3214,9 @@ static struct vm_area_struct *__install_special_mapping(
>  	int ret;
>  	struct vm_area_struct *vma;
>  
> +	if (security_check_vmflags(vm_flags))
> +		return ERR_PTR(-EPERM);
> +

And here.

>  	vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
>  	if (unlikely(vma == NULL))
>  		return ERR_PTR(-ENOMEM);
> diff --git a/security/security.c b/security/security.c
> index e390f99..25d58f0 100644
> --- a/security/security.c
> +++ b/security/security.c
> @@ -905,6 +905,11 @@ int security_file_mprotect(struct vm_area_struct *vma, unsigned long reqprot,
>  	return call_int_hook(file_mprotect, 0, vma, reqprot, prot);
>  }
>  
> +int security_check_vmflags(vm_flags_t vmflags)
> +{
> +	return call_int_hook(check_vmflags, 0, vmflags);
> +}
> +
>  int security_file_lock(struct file *file, unsigned int cmd)
>  {
>  	return call_int_hook(file_lock, 0, file, cmd);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
