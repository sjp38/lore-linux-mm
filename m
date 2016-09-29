Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5AEC56B0038
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 12:36:39 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id n13so124109240uaa.1
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 09:36:39 -0700 (PDT)
Received: from emsm-gh1-uea10.nsa.gov (emsm-gh1-uea10.nsa.gov. [8.44.101.8])
        by mx.google.com with ESMTPS id 129si4365577vko.2.2016.09.29.09.36.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Sep 2016 09:36:38 -0700 (PDT)
Subject: Re: [PATCH v2 3/3] selinux: require EXECMEM for forced ptrace poke
References: <1475103281-7989-1-git-send-email-jann@thejh.net>
 <1475103281-7989-4-git-send-email-jann@thejh.net>
From: Stephen Smalley <sds@tycho.nsa.gov>
Message-ID: <4b83b10c-2127-3d85-89a8-1d1ceccbfa3b@tycho.nsa.gov>
Date: Thu, 29 Sep 2016 12:38:53 -0400
MIME-Version: 1.0
In-Reply-To: <1475103281-7989-4-git-send-email-jann@thejh.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jann@thejh.net>, security@kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Paul Moore <paul@paul-moore.com>, Eric Paris <eparis@parisplace.org>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>
Cc: Nick Kralevich <nnk@google.com>, Janis Danisevskis <jdanis@google.com>, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/28/2016 06:54 PM, Jann Horn wrote:
> This is a breaking change for SELinux users that restrict EXECMEM: It might
> break gdb if gdb is executed in a domain that does not have EXECMEM
> privilege over the debuggee domain.

Since this would break compatibility with existing SELinux policies, you
have to wrap it with a conditional on a policy capability that you can
then enable in newer policies.  See commit
2be4d74f2fd45460d70d4fe65cc1972ef45bf849 for an example.  This requires
a corresponding update to libsepol, and then adding the new policy
capability to your policy (in the policy_capabilities file).

> 
> Unlike most other SELinux hooks, this one takes the subject credentials as
> an argument instead of looking up current_cred(). This is done because the
> security_forced_write() LSM hook can be invoked from within the write
> handler of /proc/$pid/mem, where current_cred() is pretty useless.
> 
> Signed-off-by: Jann Horn <jann@thejh.net>
> Reviewed-by: Janis Danisevskis <jdanis@android.com>
> ---
>  security/selinux/hooks.c | 15 +++++++++++++++
>  1 file changed, 15 insertions(+)
> 
> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index 13185a6..e36682a 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -2149,6 +2149,20 @@ static int selinux_ptrace_traceme(struct task_struct *parent)
>  	return task_has_perm(parent, current, PROCESS__PTRACE);
>  }
>  
> +static int selinux_forced_write(struct vm_area_struct *vma,
> +				const struct cred *subject_cred,
> +				const struct cred *object_cred)
> +{
> +	/* Permitting a write to readonly memory is fine - making the readonly
> +	 * memory executable afterwards would require EXECMOD permission because
> +	 * anon_vma would be non-NULL.
> +	 */
> +	if ((vma->vm_flags & VM_EXEC) == 0)
> +		return 0;
> +
> +	return cred_has_perm(subject_cred, object_cred, PROCESS__EXECMEM);
> +}
> +
>  static int selinux_capget(struct task_struct *target, kernel_cap_t *effective,
>  			  kernel_cap_t *inheritable, kernel_cap_t *permitted)
>  {
> @@ -6033,6 +6047,7 @@ static struct security_hook_list selinux_hooks[] = {
>  
>  	LSM_HOOK_INIT(ptrace_access_check, selinux_ptrace_access_check),
>  	LSM_HOOK_INIT(ptrace_traceme, selinux_ptrace_traceme),
> +	LSM_HOOK_INIT(forced_write, selinux_forced_write),
>  	LSM_HOOK_INIT(capget, selinux_capget),
>  	LSM_HOOK_INIT(capset, selinux_capset),
>  	LSM_HOOK_INIT(capable, selinux_capable),
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
