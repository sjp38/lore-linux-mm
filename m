Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id A4C186B0006
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 17:02:02 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 43-v6so1304539ple.19
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 14:02:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z5-v6sor21847plo.58.2018.10.23.14.02.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Oct 2018 14:02:01 -0700 (PDT)
Date: Tue, 23 Oct 2018 14:01:58 -0700
From: Joel Fernandes <joel@joelfernandes.org>
Subject: Re: [RFC PATCH 0/2] improve vmalloc allocation
Message-ID: <20181023210158.GA229730@joelaf.mtv.corp.google.com>
References: <20181022125142.GD18839@dhcp22.suse.cz>
 <20181022165253.uphv3xzqivh44o3d@pc636>
 <20181023072306.GN18839@dhcp22.suse.cz>
 <dd0c3528-9c01-12bc-3400-ca88060cb7cf@kernel.org>
 <20181023152640.GD20085@bombadil.infradead.org>
 <20181023170532.GW18839@dhcp22.suse.cz>
 <98842edb-d462-96b1-311f-27c6ebfc108a@kernel.org>
 <20181023193044.GA139403@joelaf.mtv.corp.google.com>
 <024af44a-77e1-1c61-c9b2-64ffbe4f7c49@kernel.org>
 <20181023200923.GB25444@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181023200923.GB25444@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Shuah Khan <shuah@kernel.org>, Michal Hocko <mhocko@kernel.org>, Uladzislau Rezki <urezki@gmail.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Thomas Garnier <thgarnie@google.com>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt <rostedt@goodmis.org>, Joel Fernandes <joelaf@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Tejun Heo <tj@kernel.org>, maco@android.com

On Tue, Oct 23, 2018 at 01:09:23PM -0700, Matthew Wilcox wrote:
> On Tue, Oct 23, 2018 at 01:48:32PM -0600, Shuah Khan wrote:
> > On 10/23/2018 01:30 PM, Joel Fernandes wrote:
> > > On Tue, Oct 23, 2018 at 11:13:36AM -0600, Shuah Khan wrote:
> > >> I like this proposal. I think we will open up lot of test opportunities with
> > >> this approach.
> > >>
> > >> Maybe we can use this stress test as a pilot and see where it takes us.
> > > 
> > > I am a bit worried that such an EXPORT_SYMBOL_KSELFTEST mechanism can be abused by
> > > out-of-tree module writers to call internal functionality.
> > 
> > That is  valid concern to consider before we go forward with the proposal.
> > 
> > We could wrap EXPORT_SYMBOL_KSELFTEST this in an existing debug option. This could
> > be fine grained for each sub-system for its debug option. We do have a few of these
> > now
> 
> This all seems far more complicated than my proposed solution.

Matthew's solution seems Ok to me where it works. A problem could be that it
will not always work.

As an example, recently I wanted to directly set the sysctl_sched_rt_runtime
variable from the rcutorture test, just for forcing some conditions. This
symbol is internal and inaccessible from modules. This can also be done by
calling the internal sched_rt_handler with some parameters.  However I don't
think including an internal source file in a test source file can achieve the
objective of setting it since access to the internal symbol is not possible
without exporting it somehow. This could be a "special" case too but is an
example where the include trick may fall apart.

I do think its a cool trick though ;-)

 - Joel
