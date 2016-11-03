Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5FAE16B02CB
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 09:18:54 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id h67so31250628vkf.4
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 06:18:54 -0700 (PDT)
Received: from emsm-gh1-uea10.nsa.gov (emsm-gh1-uea10.nsa.gov. [8.44.101.8])
        by mx.google.com with ESMTPS id u196si2590133vkd.207.2016.11.03.06.18.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Nov 2016 06:18:53 -0700 (PDT)
Subject: Re: [PATCH v3 3/3] selinux: require EXECMEM for forced ptrace poke
References: <1478142286-18427-1-git-send-email-jann@thejh.net>
 <1478142286-18427-6-git-send-email-jann@thejh.net>
From: Stephen Smalley <sds@tycho.nsa.gov>
Message-ID: <7b880f9b-63ac-baa6-e4ac-f751afcaffa2@tycho.nsa.gov>
Date: Thu, 3 Nov 2016 09:21:34 -0400
MIME-Version: 1.0
In-Reply-To: <1478142286-18427-6-git-send-email-jann@thejh.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jann@thejh.net>, security@kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Paul Moore <paul@paul-moore.com>, Eric Paris <eparis@parisplace.org>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, mchong@google.com, Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Nick Kralevich <nnk@google.com>, Janis Danisevskis <jdanis@google.com>
Cc: linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/02/2016 11:04 PM, Jann Horn wrote:
> This restricts forced writes to private R+X mappings using the EXECMEM
> permission. To avoid a breaking change, a new policy capability needs to
> be enabled before the new restrictions take effect.
> 
> Unlike most other SELinux hooks, this one takes the subject credentials as
> an argument instead of looking up current_cred(). This is done because the
> security_forced_write() LSM hook can be invoked from within the write
> handler of /proc/$pid/mem, where current_cred() is pretty useless.
> 
> Changed in v3:
>  - minor: symmetric comment (Ingo Molnar)
>  - use helper struct (Ingo Molnar)
>  - add new policy capability for enabling forced write checks
>    (Stephen Smalley)
> 
> Signed-off-by: Jann Horn <jann@thejh.net>
> ---
>  security/selinux/hooks.c            | 15 +++++++++++++++
>  security/selinux/include/security.h |  2 ++
>  security/selinux/selinuxfs.c        |  3 ++-
>  security/selinux/ss/services.c      |  3 +++
>  4 files changed, 22 insertions(+), 1 deletion(-)
> 
> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index 09fd6108e421..cdd9c53db2ed 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -2144,6 +2144,20 @@ static int selinux_ptrace_traceme(struct task_struct *parent)
>  	return task_has_perm(parent, current, PROCESS__PTRACE);
>  }
>  
> +static int selinux_forced_write(struct vm_area_struct *vma,
> +				const struct gup_creds *creds)
> +{
> +	/*
> +	 * Permitting a write to readonly memory is fine - making the readonly
> +	 * memory executable afterwards would require EXECMOD permission because
> +	 * anon_vma would be non-NULL.
> +	 */
> +	if (!selinux_policycap_forcedwrite || (vma->vm_flags & VM_EXEC) == 0)
> +		return 0;
> +
> +	return cred_has_perm(creds->subject, creds->object, PROCESS__EXECMEM);
> +}
> +
>  static int selinux_capget(struct task_struct *target, kernel_cap_t *effective,
>  			  kernel_cap_t *inheritable, kernel_cap_t *permitted)
>  {
> @@ -6085,6 +6099,7 @@ static struct security_hook_list selinux_hooks[] = {
>  
>  	LSM_HOOK_INIT(ptrace_access_check, selinux_ptrace_access_check),
>  	LSM_HOOK_INIT(ptrace_traceme, selinux_ptrace_traceme),
> +	LSM_HOOK_INIT(forced_write, selinux_forced_write),
>  	LSM_HOOK_INIT(capget, selinux_capget),
>  	LSM_HOOK_INIT(capset, selinux_capset),
>  	LSM_HOOK_INIT(capable, selinux_capable),
> diff --git a/security/selinux/include/security.h b/security/selinux/include/security.h
> index 308a286c6cbe..87228f0ff09c 100644
> --- a/security/selinux/include/security.h
> +++ b/security/selinux/include/security.h
> @@ -71,6 +71,7 @@ enum {
>  	POLICYDB_CAPABILITY_OPENPERM,
>  	POLICYDB_CAPABILITY_REDHAT1,
>  	POLICYDB_CAPABILITY_ALWAYSNETWORK,
> +	POLICYDB_CAPABILITY_FORCEDWRITE,
>  	__POLICYDB_CAPABILITY_MAX
>  };
>  #define POLICYDB_CAPABILITY_MAX (__POLICYDB_CAPABILITY_MAX - 1)
> @@ -78,6 +79,7 @@ enum {
>  extern int selinux_policycap_netpeer;
>  extern int selinux_policycap_openperm;
>  extern int selinux_policycap_alwaysnetwork;
> +extern int selinux_policycap_forcedwrite;
>  
>  /*
>   * type_datum properties
> diff --git a/security/selinux/selinuxfs.c b/security/selinux/selinuxfs.c
> index 72c145dd799f..a646cb801242 100644
> --- a/security/selinux/selinuxfs.c
> +++ b/security/selinux/selinuxfs.c
> @@ -46,7 +46,8 @@ static char *policycap_names[] = {
>  	"network_peer_controls",
>  	"open_perms",
>  	"redhat1",
> -	"always_check_network"
> +	"always_check_network",
> +	"forced_write"

This is a nit, but can you provide a more descriptive capability name
that would be meaningful to policy writers and signifies that this
policy capability enables checking execmem in these situations?

>  };
>  
>  unsigned int selinux_checkreqprot = CONFIG_SECURITY_SELINUX_CHECKREQPROT_VALUE;
> diff --git a/security/selinux/ss/services.c b/security/selinux/ss/services.c
> index 082b20c78363..4017810030d6 100644
> --- a/security/selinux/ss/services.c
> +++ b/security/selinux/ss/services.c
> @@ -73,6 +73,7 @@
>  int selinux_policycap_netpeer;
>  int selinux_policycap_openperm;
>  int selinux_policycap_alwaysnetwork;
> +int selinux_policycap_forcedwrite;
>  
>  static DEFINE_RWLOCK(policy_rwlock);
>  
> @@ -1990,6 +1991,8 @@ static void security_load_policycaps(void)
>  						  POLICYDB_CAPABILITY_OPENPERM);
>  	selinux_policycap_alwaysnetwork = ebitmap_get_bit(&policydb.policycaps,
>  						  POLICYDB_CAPABILITY_ALWAYSNETWORK);
> +	selinux_policycap_forcedwrite = ebitmap_get_bit(&policydb.policycaps,
> +						  POLICYDB_CAPABILITY_FORCEDWRITE);
>  }
>  
>  static int security_preserve_bools(struct policydb *p);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
