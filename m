Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 56B3A6B000D
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 03:40:01 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id z13-v6so12497640pgv.18
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 00:40:01 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l186si25271579pge.205.2018.11.15.00.39.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 00:40:00 -0800 (PST)
Date: Thu, 15 Nov 2018 09:39:57 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/1] vmalloc: add test driver to analyse vmalloc
 allocator
Message-ID: <20181115083957.GE23831@dhcp22.suse.cz>
References: <20181113151629.14826-1-urezki@gmail.com>
 <20181113151629.14826-2-urezki@gmail.com>
 <20181113141046.f62f5bd88d4ebc663b0ac100@linux-foundation.org>
 <20181114151737.GA23419@dhcp22.suse.cz>
 <20181114150053.c3fe42507923322a0a10ae1c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181114150053.c3fe42507923322a0a10ae1c@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Uladzislau Rezki (Sony)" <urezki@gmail.com>, Kees Cook <keescook@chromium.org>, Shuah Khan <shuah@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Matthew Wilcox <willy@infradead.org>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Thomas Gleixner <tglx@linutronix.de>

On Wed 14-11-18 15:00:53, Andrew Morton wrote:
> On Wed, 14 Nov 2018 16:17:37 +0100 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Tue 13-11-18 14:10:46, Andrew Morton wrote:
> > [...]
> > > > +static int vmalloc_test_init(void)
> > > > +{
> > > > +	__my_vmalloc_node_range =
> > > > +		(void *) kallsyms_lookup_name("__vmalloc_node_range");
> > > > +
> > > > +	if (__my_vmalloc_node_range)
> > > > +		do_concurrent_test();
> > > > +
> > > > +	return -EAGAIN; /* Fail will directly unload the module */
> > > > +}
> > > 
> > > It's unclear why this module needs access to the internal
> > > __vmalloc_node_range().  Please fully explain this in the changelog.
> > > 
> > > Then, let's just export the thing.  (I expect this module needs a
> > > Kconfig dependency on CONFIG_KALLSYMS, btw).  A suitable way of doing
> > > that would be
> > > 
> > > /* Exported for lib/test_vmalloc.c.  Please do not use elsewhere */
> > > EXPORT_SYMBOL_GPL(__vmalloc_node_range);
> > 
> > There was a previous discussion that testing for internal infrastructure
> > is useful quite often and such a testing module needs an access to such
> > an internal infrastructure. Exporting those symbols via standard
> > EXPORT_SYMBOL_GPL is far from optimal because we can be pretty much sure
> > an abuse will arise sooner than later. I was proposing
> > EXPORT_SYMBOL_SELFTEST that would link only against testing modules.
> 
> That's rather overdoing things, I think.  If someone uses a
> dont-use-this symbol then they get to own both pieces when it breaks.

I do not think this has ever worked out. People are abusing internal
stuff and then we have to live with that. That is my experience at
least.

> We could simply do
> 
> #define EXPORT_SYMBOL_SELFTEST EXPORT_SYMBOL_GPL
>
> then write a script which checks the tree for usages of the
> thus-tagged symbols outside tools/testing and lib/ (?)

and then yell at people? We can try it out of course. The namespace
would be quite clear and we could document the supported usage pattern.
We also want to make EXPORT_SYMBOL_SELFTEST conditional. EXPORTs are not
free and we do not want to add them if the whole testing infrastructure
is disabled (assuming there is a global one for that).

> > If that is not viable for some reason then kallsyms_lookup_name is a
> > dirty-but-usable workaround.
> 
> Well yes.  It adds a dependency on CONFIG_KALLSYMS and will cause
> silent breakage if __vmalloc_node_range gets renamed, has its arguments
> changed, etc.

Yeah, I've said dirty ;)

-- 
Michal Hocko
SUSE Labs
