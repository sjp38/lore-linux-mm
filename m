Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B796C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 07:56:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DDF652054F
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 07:56:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DDF652054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D6A06B0005; Wed, 14 Aug 2019 03:56:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 65FE36B0006; Wed, 14 Aug 2019 03:56:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 526A36B0007; Wed, 14 Aug 2019 03:56:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0042.hostedemail.com [216.40.44.42])
	by kanga.kvack.org (Postfix) with ESMTP id 27E536B0005
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 03:56:06 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id B4F608248AA1
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 07:56:05 +0000 (UTC)
X-FDA: 75820275090.24.meal80_352625d630f3e
X-HE-Tag: meal80_352625d630f3e
X-Filterd-Recvd-Size: 6462
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf10.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 07:56:05 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2336EACBA;
	Wed, 14 Aug 2019 07:56:03 +0000 (UTC)
Date: Wed, 14 Aug 2019 09:56:01 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Jann Horn <jannh@google.com>
Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>,
	"Joel Fernandes (Google)" <joel@joelfernandes.org>,
	kernel list <linux-kernel@vger.kernel.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Borislav Petkov <bp@alien8.de>, Brendan Gregg <bgregg@netflix.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christian Hansen <chansen3@cisco.com>,
	Daniel Colascione <dancol@google.com>, fmayer@google.com,
	"H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
	Joel Fernandes <joelaf@google.com>,
	Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>,
	kernel-team <kernel-team@android.com>,
	Linux API <linux-api@vger.kernel.org>, linux-doc@vger.kernel.org,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Linux-MM <linux-mm@kvack.org>, Mike Rapoport <rppt@linux.ibm.com>,
	Minchan Kim <minchan@kernel.org>, namhyung@google.com,
	"Paul E. McKenney" <paulmck@linux.ibm.com>,
	Robin Murphy <robin.murphy@arm.com>, Roman Gushchin <guro@fb.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Suren Baghdasaryan <surenb@google.com>,
	Thomas Gleixner <tglx@linutronix.de>, Todd Kjos <tkjos@google.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will@kernel.org>
Subject: Re: [PATCH v5 1/6] mm/page_idle: Add per-pid idle page tracking
 using virtual index
Message-ID: <20190814075601.GO17933@dhcp22.suse.cz>
References: <20190807171559.182301-1-joel@joelfernandes.org>
 <CAG48ez0ysprvRiENhBkLeV9YPTN_MB18rbu2HDa2jsWo5FYR8g@mail.gmail.com>
 <20190813100856.GF17933@dhcp22.suse.cz>
 <CAG48ez2cuqe_VYhhaqw8Hcyswv47cmz2XmkqNdvkXEhokMVaXg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG48ez2cuqe_VYhhaqw8Hcyswv47cmz2XmkqNdvkXEhokMVaXg@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 13-08-19 17:29:09, Jann Horn wrote:
> On Tue, Aug 13, 2019 at 12:09 PM Michal Hocko <mhocko@kernel.org> wrote:
> > On Mon 12-08-19 20:14:38, Jann Horn wrote:
> > > On Wed, Aug 7, 2019 at 7:16 PM Joel Fernandes (Google)
> > > <joel@joelfernandes.org> wrote:
> > > > The page_idle tracking feature currently requires looking up the pagemap
> > > > for a process followed by interacting with /sys/kernel/mm/page_idle.
> > > > Looking up PFN from pagemap in Android devices is not supported by
> > > > unprivileged process and requires SYS_ADMIN and gives 0 for the PFN.
> > > >
> > > > This patch adds support to directly interact with page_idle tracking at
> > > > the PID level by introducing a /proc/<pid>/page_idle file.  It follows
> > > > the exact same semantics as the global /sys/kernel/mm/page_idle, but now
> > > > looking up PFN through pagemap is not needed since the interface uses
> > > > virtual frame numbers, and at the same time also does not require
> > > > SYS_ADMIN.
> > > >
> > > > In Android, we are using this for the heap profiler (heapprofd) which
> > > > profiles and pin points code paths which allocates and leaves memory
> > > > idle for long periods of time. This method solves the security issue
> > > > with userspace learning the PFN, and while at it is also shown to yield
> > > > better results than the pagemap lookup, the theory being that the window
> > > > where the address space can change is reduced by eliminating the
> > > > intermediate pagemap look up stage. In virtual address indexing, the
> > > > process's mmap_sem is held for the duration of the access.
> > >
> > > What happens when you use this interface on shared pages, like memory
> > > inherited from the zygote, library file mappings and so on? If two
> > > profilers ran concurrently for two different processes that both map
> > > the same libraries, would they end up messing up each other's data?
> >
> > Yup PageIdle state is shared. That is the page_idle semantic even now
> > IIRC.
> >
> > > Can this be used to observe which library pages other processes are
> > > accessing, even if you don't have access to those processes, as long
> > > as you can map the same libraries? I realize that there are already a
> > > bunch of ways to do that with side channels and such; but if you're
> > > adding an interface that allows this by design, it seems to me like
> > > something that should be gated behind some sort of privilege check.
> >
> > Hmm, you need to be priviledged to get the pfn now and without that you
> > cannot get to any page so the new interface is weakening the rules.
> > Maybe we should limit setting the idle state to processes with the write
> > status. Or do you think that even observing idle status is useful for
> > practical side channel attacks? If yes, is that a problem of the
> > profiler which does potentially dangerous things?
> 
> I suppose read-only access isn't a real problem as long as the
> profiler isn't writing the idle state in a very tight loop... but I
> don't see a usecase where you'd actually want that? As far as I can
> tell, if you can't write the idle state, being able to read it is
> pretty much useless.
> 
> If the profiler only wants to profile process-private memory, then
> that should be implementable in a safe way in principle, I think, but
> since Joel said that they want to profile CoW memory as well, I think
> that's inherently somewhat dangerous.

I cannot really say how useful that would be but I can see that
implementing ownership checks would be really non-trivial for
shared pages. Reducing the interface to exclusive pages would make it
easier as you noted but less helpful.

Besides that the attack vector shouldn't be really much different from
the page cache access, right? So essentially can_do_mincore model.

I guess we want to document that page idle tracking should be used with
care because it potentially opens a side channel opportunity if used
on sensitive data.
-- 
Michal Hocko
SUSE Labs

