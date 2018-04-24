Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id EFCEE6B000C
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 08:48:10 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id r104-v6so7745255ota.19
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 05:48:10 -0700 (PDT)
Received: from uhil19pa09.eemsg.mail.mil (uhil19pa09.eemsg.mail.mil. [214.24.21.82])
        by mx.google.com with ESMTP id g15-v6si4995735otk.366.2018.04.24.05.48.08
        for <linux-mm@kvack.org>;
        Tue, 24 Apr 2018 05:48:09 -0700 (PDT)
Subject: Re: [PATCH 9/9] Protect SELinux initialized state with pmalloc
References: <20180423125458.5338-1-igor.stoppa@huawei.com>
 <20180423125458.5338-10-igor.stoppa@huawei.com>
From: Stephen Smalley <sds@tycho.nsa.gov>
Message-ID: <13ee6991-db48-d484-66a6-90de45fad2df@tycho.nsa.gov>
Date: Tue, 24 Apr 2018 08:49:20 -0400
MIME-Version: 1.0
In-Reply-To: <20180423125458.5338-10-igor.stoppa@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@gmail.com>, willy@infradead.org, keescook@chromium.org, paul@paul-moore.com, mhocko@kernel.org, corbet@lwn.net
Cc: labbott@redhat.com, david@fromorbit.com, rppt@linux.vnet.ibm.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Igor Stoppa <igor.stoppa@huawei.com>

On 04/23/2018 08:54 AM, Igor Stoppa wrote:
> SELinux is one of the primary targets, when a system running it comes
> under attack.
> 
> The reason is that, even if an attacker ishould manage to gain root,
> SELinux will still prevent most desirable actions.
> 
> Even in a fully locked down system, SELinux still presents a vulnerability
> that is often exploited, because it is very simple to attack, once
> kernel address layout randomization has been defeated and the attacker
> has gained capability of writing to kernelunprotected data.
> 
> In various places, SELinux relies on an "initialized" internal state
> variable, to decide if the policy is loaded and tests should be
> performed. Needless to say, it's in the interest of hte attacker to turn
> it off and pretend that the policyDB is still uninitialized.
> 
> Even if recent patches move the "initialized" state inside a structure,
> it is still vulnerable.
> 
> This patch seeks to protect it, using it as demo for the pmalloc API,
> which is meant to provide additional protection to data which is likely
> to not be changed very often, if ever (after a transient).
> 
> The patch is probably in need of rework, to make it fit better with the
> new SELinux internal data structures, however it shows how to deny an
> easy target to the attacker.

I know this is just an example, but not sure why you wouldn't just protect the
entire selinux_state.  Note btw that the selinux_state encapsulation is preparatory work
for selinux namespaces [1], at which point the structure is in fact dynamically allocated
and there can be multiple instances of it.  That however is work-in-progress, highly experimental,
and might not ever make it upstream (if we can't resolve the various challenges it poses in a satisfactory
way).

[1] http://blog.namei.org/2018/01/22/lca-2018-kernel-miniconf-selinux-namespacing-slides/


> 
> In case the kernel is compiled with JOP safeguards, then it becomes far
> harder for the attacker to jump into the middle of the function which
> calls pmalloc_rare_write, to alter the state.
> 
> Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
> ---
>  security/selinux/hooks.c            | 12 ++++-----
>  security/selinux/include/security.h |  2 +-
>  security/selinux/ss/services.c      | 51 +++++++++++++++++++++++--------------
>  3 files changed, 39 insertions(+), 26 deletions(-)
> 
> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index 4cafe6a19167..6049f80115bc 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -285,7 +285,7 @@ static int __inode_security_revalidate(struct inode *inode,
>  
>  	might_sleep_if(may_sleep);
>  
> -	if (selinux_state.initialized &&
> +	if (*ss_initialized_ptr &&
>  	    isec->initialized != LABEL_INITIALIZED) {
>  		if (!may_sleep)
>  			return -ECHILD;
> @@ -612,7 +612,7 @@ static int selinux_get_mnt_opts(const struct super_block *sb,
>  	if (!(sbsec->flags & SE_SBINITIALIZED))
>  		return -EINVAL;
>  
> -	if (!selinux_state.initialized)
> +	if (!*ss_initialized_ptr)
>  		return -EINVAL;
>  
>  	/* make sure we always check enough bits to cover the mask */
> @@ -735,7 +735,7 @@ static int selinux_set_mnt_opts(struct super_block *sb,
>  
>  	mutex_lock(&sbsec->lock);
>  
> -	if (!selinux_state.initialized) {
> +	if (!*ss_initialized_ptr) {
>  		if (!num_opts) {
>  			/* Defer initialization until selinux_complete_init,
>  			   after the initial policy is loaded and the security
> @@ -1022,7 +1022,7 @@ static int selinux_sb_clone_mnt_opts(const struct super_block *oldsb,
>  	 * if the parent was able to be mounted it clearly had no special lsm
>  	 * mount options.  thus we can safely deal with this superblock later
>  	 */
> -	if (!selinux_state.initialized)
> +	if (!*ss_initialized_ptr)
>  		return 0;
>  
>  	/*
> @@ -3040,7 +3040,7 @@ static int selinux_inode_init_security(struct inode *inode, struct inode *dir,
>  		isec->initialized = LABEL_INITIALIZED;
>  	}
>  
> -	if (!selinux_state.initialized || !(sbsec->flags & SBLABEL_MNT))
> +	if (!*ss_initialized_ptr || !(sbsec->flags & SBLABEL_MNT))
>  		return -EOPNOTSUPP;
>  
>  	if (name)
> @@ -7253,7 +7253,7 @@ static void selinux_nf_ip_exit(void)
>  #ifdef CONFIG_SECURITY_SELINUX_DISABLE
>  int selinux_disable(struct selinux_state *state)
>  {
> -	if (state->initialized) {
> +	if (*ss_initialized_ptr) {
>  		/* Not permitted after initial policy load. */
>  		return -EINVAL;
>  	}
> diff --git a/security/selinux/include/security.h b/security/selinux/include/security.h
> index 23e762d529fa..ec7debb143be 100644
> --- a/security/selinux/include/security.h
> +++ b/security/selinux/include/security.h
> @@ -96,13 +96,13 @@ extern char *selinux_policycap_names[__POLICYDB_CAPABILITY_MAX];
>  struct selinux_avc;
>  struct selinux_ss;
>  
> +extern bool *ss_initialized_ptr;
>  struct selinux_state {
>  	bool disabled;
>  #ifdef CONFIG_SECURITY_SELINUX_DEVELOP
>  	bool enforcing;
>  #endif
>  	bool checkreqprot;
> -	bool initialized;
>  	bool policycap[__POLICYDB_CAPABILITY_MAX];
>  	struct selinux_avc *avc;
>  	struct selinux_ss *ss;
> diff --git a/security/selinux/ss/services.c b/security/selinux/ss/services.c
> index 8057e19dc15f..c09ca6f9b269 100644
> --- a/security/selinux/ss/services.c
> +++ b/security/selinux/ss/services.c
> @@ -52,6 +52,7 @@
>  #include <linux/selinux.h>
>  #include <linux/flex_array.h>
>  #include <linux/vmalloc.h>
> +#include <linux/pmalloc.h>
>  #include <net/netlabel.h>
>  
>  #include "flask.h"
> @@ -80,10 +81,20 @@ char *selinux_policycap_names[__POLICYDB_CAPABILITY_MAX] = {
>  	"nnp_nosuid_transition"
>  };
>  
> +bool *ss_initialized_ptr __ro_after_init;
> +static struct pmalloc_pool *selinux_pool;
>  static struct selinux_ss selinux_ss;
>  
>  void selinux_ss_init(struct selinux_ss **ss)
>  {
> +	selinux_pool = pmalloc_create_pool(PMALLOC_RW);
> +	if (unlikely(!selinux_pool))
> +		panic("SELinux: unable to create pmalloc pool.");
> +	ss_initialized_ptr = pmalloc(selinux_pool, sizeof(bool));
> +	if (unlikely(!ss_initialized_ptr))
> +		panic("SElinux: unable to allocate from pmalloc pool.");
> +	*ss_initialized_ptr = false;
> +	pmalloc_protect_pool(selinux_pool);
>  	rwlock_init(&selinux_ss.policy_rwlock);
>  	mutex_init(&selinux_ss.status_lock);
>  	*ss = &selinux_ss;
> @@ -772,7 +783,7 @@ static int security_compute_validatetrans(struct selinux_state *state,
>  	int rc = 0;
>  
>  
> -	if (!state->initialized)
> +	if (!*ss_initialized_ptr)
>  		return 0;
>  
>  	read_lock(&state->ss->policy_rwlock);
> @@ -872,7 +883,7 @@ int security_bounded_transition(struct selinux_state *state,
>  	int index;
>  	int rc;
>  
> -	if (!state->initialized)
> +	if (!*ss_initialized_ptr)
>  		return 0;
>  
>  	read_lock(&state->ss->policy_rwlock);
> @@ -1032,7 +1043,7 @@ void security_compute_xperms_decision(struct selinux_state *state,
>  	memset(xpermd->dontaudit->p, 0, sizeof(xpermd->dontaudit->p));
>  
>  	read_lock(&state->ss->policy_rwlock);
> -	if (!state->initialized)
> +	if (!*ss_initialized_ptr)
>  		goto allow;
>  
>  	policydb = &state->ss->policydb;
> @@ -1121,7 +1132,7 @@ void security_compute_av(struct selinux_state *state,
>  	read_lock(&state->ss->policy_rwlock);
>  	avd_init(state, avd);
>  	xperms->len = 0;
> -	if (!state->initialized)
> +	if (!*ss_initialized_ptr)
>  		goto allow;
>  
>  	policydb = &state->ss->policydb;
> @@ -1175,7 +1186,7 @@ void security_compute_av_user(struct selinux_state *state,
>  
>  	read_lock(&state->ss->policy_rwlock);
>  	avd_init(state, avd);
> -	if (!state->initialized)
> +	if (!*ss_initialized_ptr)
>  		goto allow;
>  
>  	policydb = &state->ss->policydb;
> @@ -1294,7 +1305,7 @@ static int security_sid_to_context_core(struct selinux_state *state,
>  		*scontext = NULL;
>  	*scontext_len  = 0;
>  
> -	if (!state->initialized) {
> +	if (!*ss_initialized_ptr) {
>  		if (sid <= SECINITSID_NUM) {
>  			char *scontextp;
>  
> @@ -1466,7 +1477,7 @@ static int security_context_to_sid_core(struct selinux_state *state,
>  	if (!scontext2)
>  		return -ENOMEM;
>  
> -	if (!state->initialized) {
> +	if (!*ss_initialized_ptr) {
>  		int i;
>  
>  		for (i = 1; i < SECINITSID_NUM; i++) {
> @@ -1648,7 +1659,7 @@ static int security_compute_sid(struct selinux_state *state,
>  	int rc = 0;
>  	bool sock;
>  
> -	if (!state->initialized) {
> +	if (!*ss_initialized_ptr) {
>  		switch (orig_tclass) {
>  		case SECCLASS_PROCESS: /* kernel value */
>  			*out_sid = ssid;
> @@ -2128,7 +2139,8 @@ int security_load_policy(struct selinux_state *state, void *data, size_t len)
>  	policydb = &state->ss->policydb;
>  	sidtab = &state->ss->sidtab;
>  
> -	if (!state->initialized) {
> +	if (!*ss_initialized_ptr) {
> +		bool dummy_initialized = true;
>  		rc = policydb_read(policydb, fp);
>  		if (rc)
>  			goto out;
> @@ -2148,7 +2160,8 @@ int security_load_policy(struct selinux_state *state, void *data, size_t len)
>  		}
>  
>  		security_load_policycaps(state);
> -		state->initialized = 1;
> +		pmalloc_rare_write(selinux_pool, ss_initialized_ptr,
> +				   &dummy_initialized, sizeof(bool));
>  		seqno = ++state->ss->latest_granting;
>  		selinux_complete_init();
>  		avc_ss_reset(state->avc, seqno);
> @@ -2578,7 +2591,7 @@ int security_get_user_sids(struct selinux_state *state,
>  	*sids = NULL;
>  	*nel = 0;
>  
> -	if (!state->initialized)
> +	if (!*ss_initialized_ptr)
>  		goto out;
>  
>  	read_lock(&state->ss->policy_rwlock);
> @@ -2812,7 +2825,7 @@ int security_get_bools(struct selinux_state *state,
>  	struct policydb *policydb;
>  	int i, rc;
>  
> -	if (!state->initialized) {
> +	if (!*ss_initialized_ptr) {
>  		*len = 0;
>  		*names = NULL;
>  		*values = NULL;
> @@ -2987,7 +3000,7 @@ int security_sid_mls_copy(struct selinux_state *state,
>  	int rc;
>  
>  	rc = 0;
> -	if (!state->initialized || !policydb->mls_enabled) {
> +	if (!*ss_initialized_ptr || !policydb->mls_enabled) {
>  		*new_sid = sid;
>  		goto out;
>  	}
> @@ -3094,7 +3107,7 @@ int security_net_peersid_resolve(struct selinux_state *state,
>  	/*
>  	 * We don't need to check initialized here since the only way both
>  	 * nlbl_sid and xfrm_sid are not equal to SECSID_NULL would be if the
> -	 * security server was initialized and state->initialized was true.
> +	 * security server was initialized and *ss_initialized_ptr was true.
>  	 */
>  	if (!policydb->mls_enabled)
>  		return 0;
> @@ -3149,7 +3162,7 @@ int security_get_classes(struct selinux_state *state,
>  	struct policydb *policydb = &state->ss->policydb;
>  	int rc;
>  
> -	if (!state->initialized) {
> +	if (!*ss_initialized_ptr) {
>  		*nclasses = 0;
>  		*classes = NULL;
>  		return 0;
> @@ -3298,7 +3311,7 @@ int selinux_audit_rule_init(u32 field, u32 op, char *rulestr, void **vrule)
>  
>  	*rule = NULL;
>  
> -	if (!state->initialized)
> +	if (!*ss_initialized_ptr)
>  		return -EOPNOTSUPP;
>  
>  	switch (field) {
> @@ -3598,7 +3611,7 @@ int security_netlbl_secattr_to_sid(struct selinux_state *state,
>  	struct context *ctx;
>  	struct context ctx_new;
>  
> -	if (!state->initialized) {
> +	if (!*ss_initialized_ptr) {
>  		*sid = SECSID_NULL;
>  		return 0;
>  	}
> @@ -3665,7 +3678,7 @@ int security_netlbl_sid_to_secattr(struct selinux_state *state,
>  	int rc;
>  	struct context *ctx;
>  
> -	if (!state->initialized)
> +	if (!*ss_initialized_ptr)
>  		return 0;
>  
>  	read_lock(&state->ss->policy_rwlock);
> @@ -3704,7 +3717,7 @@ int security_read_policy(struct selinux_state *state,
>  	int rc;
>  	struct policy_file fp;
>  
> -	if (!state->initialized)
> +	if (!*ss_initialized_ptr)
>  		return -EINVAL;
>  
>  	*len = security_policydb_len(state);
> 
