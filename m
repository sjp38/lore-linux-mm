Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 29F1B6B0003
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 10:17:40 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id y35so4976386edb.5
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 07:17:40 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c5si4536054edw.204.2018.11.14.07.17.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 07:17:38 -0800 (PST)
Date: Wed, 14 Nov 2018 16:17:37 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/1] vmalloc: add test driver to analyse vmalloc
 allocator
Message-ID: <20181114151737.GA23419@dhcp22.suse.cz>
References: <20181113151629.14826-1-urezki@gmail.com>
 <20181113151629.14826-2-urezki@gmail.com>
 <20181113141046.f62f5bd88d4ebc663b0ac100@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181113141046.f62f5bd88d4ebc663b0ac100@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Uladzislau Rezki (Sony)" <urezki@gmail.com>, Kees Cook <keescook@chromium.org>, Shuah Khan <shuah@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Matthew Wilcox <willy@infradead.org>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Thomas Gleixner <tglx@linutronix.de>

On Tue 13-11-18 14:10:46, Andrew Morton wrote:
[...]
> > +static int vmalloc_test_init(void)
> > +{
> > +	__my_vmalloc_node_range =
> > +		(void *) kallsyms_lookup_name("__vmalloc_node_range");
> > +
> > +	if (__my_vmalloc_node_range)
> > +		do_concurrent_test();
> > +
> > +	return -EAGAIN; /* Fail will directly unload the module */
> > +}
> 
> It's unclear why this module needs access to the internal
> __vmalloc_node_range().  Please fully explain this in the changelog.
> 
> Then, let's just export the thing.  (I expect this module needs a
> Kconfig dependency on CONFIG_KALLSYMS, btw).  A suitable way of doing
> that would be
> 
> /* Exported for lib/test_vmalloc.c.  Please do not use elsewhere */
> EXPORT_SYMBOL_GPL(__vmalloc_node_range);

There was a previous discussion that testing for internal infrastructure
is useful quite often and such a testing module needs an access to such
an internal infrastructure. Exporting those symbols via standard
EXPORT_SYMBOL_GPL is far from optimal because we can be pretty much sure
an abuse will arise sooner than later. I was proposing
EXPORT_SYMBOL_SELFTEST that would link only against testing modules.

If that is not viable for some reason then kallsyms_lookup_name is a
dirty-but-usable workaround.
-- 
Michal Hocko
SUSE Labs
