Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 80D666B0003
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 13:34:29 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id k1-v6so2213311ljk.9
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 10:34:29 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j14-v6sor1834198lfc.69.2018.10.24.10.34.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Oct 2018 10:34:27 -0700 (PDT)
From: Uladzislau Rezki <urezki@gmail.com>
Date: Wed, 24 Oct 2018 19:34:18 +0200
Subject: Re: [RFC PATCH 0/2] improve vmalloc allocation
Message-ID: <20181024173418.2bxkdjbcyzfkgfeu@pc636>
References: <20181019173538.590-1-urezki@gmail.com>
 <20181022125142.GD18839@dhcp22.suse.cz>
 <20181022165253.uphv3xzqivh44o3d@pc636>
 <20181023072306.GN18839@dhcp22.suse.cz>
 <dd0c3528-9c01-12bc-3400-ca88060cb7cf@kernel.org>
 <20181023152640.GD20085@bombadil.infradead.org>
 <20181023170532.GW18839@dhcp22.suse.cz>
 <98842edb-d462-96b1-311f-27c6ebfc108a@kernel.org>
 <20181023193044.GA139403@joelaf.mtv.corp.google.com>
 <20181024062252.GA18839@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181024062252.GA18839@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Joel Fernandes <joel@joelfernandes.org>, Shuah Khan <shuah@kernel.org>, Matthew Wilcox <willy@infradead.org>, Uladzislau Rezki <urezki@gmail.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Thomas Garnier <thgarnie@google.com>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt <rostedt@goodmis.org>, Joel Fernandes <joelaf@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Tejun Heo <tj@kernel.org>, maco@android.com

Hi.

On Wed, Oct 24, 2018 at 08:22:52AM +0200, Michal Hocko wrote:
> On Tue 23-10-18 12:30:44, Joel Fernandes wrote:
> > On Tue, Oct 23, 2018 at 11:13:36AM -0600, Shuah Khan wrote:
> > > On 10/23/2018 11:05 AM, Michal Hocko wrote:
> > > > On Tue 23-10-18 08:26:40, Matthew Wilcox wrote:
> > > >> On Tue, Oct 23, 2018 at 09:02:56AM -0600, Shuah Khan wrote:
> > > > [...]
> > > >>> The way it can be handled is by adding a test module under lib. test_kmod,
> > > >>> test_sysctl, test_user_copy etc.
> > > >>
> > > >> The problem is that said module can only invoke functions which are
> > > >> exported using EXPORT_SYMBOL.  And there's a cost to exporting them,
> > > >> which I don't think we're willing to pay, purely to get test coverage.
> > > > 
> > > > Yes, I think we do not want to export internal functionality which might
> > > > be still interesting for the testing coverage. Maybe we want something
> > > > like EXPORT_SYMBOL_KSELFTEST which would allow to link within the
> > > > kselftest machinery but it wouldn't allow the same for general modules
> > > > and will not give any API promisses.
> > > > 
> > > 
> > > I like this proposal. I think we will open up lot of test opportunities with
> > > this approach.
> > > 
> > > Maybe we can use this stress test as a pilot and see where it takes us.
> > 
> > I am a bit worried that such an EXPORT_SYMBOL_KSELFTEST mechanism can be abused by
> > out-of-tree module writers to call internal functionality.
> > 
> > How would you prevent that?
> 
> There is no way to prevent non-exported symbols abuse by 3rd party
> AFAIK. EXPORT_SYMBOL_* is not there to prohibid abuse. It is a mere
> signal of what is, well, an exported API.
> -- 
> Michal Hocko
> SUSE Labs

Can we just use kallsyms_lookup_name()?

<snip>
static void *((*__my_vmalloc_node_range)(unsigned long size,
    unsigned long align,unsigned long start, unsigned long end,
    gfp_t gfp_mask,pgprot_t prot, unsigned long vm_flags,
    int node, const void *caller));

__my_vmalloc_node_range = (void *) kallsyms_lookup_name("__vmalloc_node_range");
<snip>

--
Vlad Rezki
