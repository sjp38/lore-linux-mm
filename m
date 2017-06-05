Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2B2DD6B0292
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 16:50:57 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id q27so149199810pfi.8
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 13:50:57 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id m66si31973932pfc.39.2017.06.05.13.50.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 05 Jun 2017 13:50:56 -0700 (PDT)
Subject: Re: [PATCH 4/5] Make LSM Writable Hooks a command line option
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170605192216.21596-1-igor.stoppa@huawei.com>
	<20170605192216.21596-5-igor.stoppa@huawei.com>
	<71e91de0-7d91-79f4-67f0-be0afb33583c@schaufler-ca.com>
In-Reply-To: <71e91de0-7d91-79f4-67f0-be0afb33583c@schaufler-ca.com>
Message-Id: <201706060550.HAC69712.OVFOtSFLQJOMFH@I-love.SAKURA.ne.jp>
Date: Tue, 6 Jun 2017 05:50:11 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: casey@schaufler-ca.com, igor.stoppa@huawei.com, keescook@chromium.org, mhocko@kernel.org, jmorris@namei.org
Cc: paul@paul-moore.com, sds@tycho.nsa.gov, hch@infradead.org, labbott@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

Casey Schaufler wrote:
> > @@ -33,8 +34,17 @@
> >  /* Maximum number of letters for an LSM name string */
> >  #define SECURITY_NAME_MAX	10
> >  
> > -static struct list_head hook_heads[LSM_MAX_HOOK_INDEX]
> > -	__lsm_ro_after_init;
> > +static int security_debug;
> > +
> > +static __init int set_security_debug(char *str)
> > +{
> > +	get_option(&str, &security_debug);
> > +	return 0;
> > +}
> > +early_param("security_debug", set_security_debug);
> 
> I don't care for calling this "security debug". Making
> the lists writable after init isn't about development,
> it's about (Tetsuo's desire for) dynamic module loading.
> I would prefer "dynamic_module_lists" our something else
> more descriptive.

Maybe dynamic_lsm ?

> 
> > +
> > +static struct list_head *hook_heads;
> > +static struct pmalloc_pool *sec_pool;
> >  char *lsm_names;
> >  /* Boot-time LSM user choice */
> >  static __initdata char chosen_lsm[SECURITY_NAME_MAX + 1] =
> > @@ -59,6 +69,13 @@ int __init security_init(void)
> >  {
> >  	enum security_hook_index i;
> >  
> > +	sec_pool = pmalloc_create_pool("security");
> > +	if (!sec_pool)
> > +		goto error_pool;
> 
> Excessive gotoing - return -ENOMEM instead.

But does it make sense to continue?
hook_heads == NULL and we will oops as soon as
call_void_hook() or call_int_hook() is called for the first time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
