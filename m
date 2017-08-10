Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 82CA86B02C3
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 13:01:50 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id y206so3704321wmd.1
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 10:01:50 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 138si5174694wmu.160.2017.08.10.10.01.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 Aug 2017 10:01:49 -0700 (PDT)
Date: Thu, 10 Aug 2017 19:01:44 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 0/2] mm,fork,security: introduce MADV_WIPEONFORK
Message-ID: <20170810170144.GA987@dhcp22.suse.cz>
References: <20170806140425.20937-1-riel@redhat.com>
 <20170807132257.GH32434@dhcp22.suse.cz>
 <20170807134648.GI32434@dhcp22.suse.cz>
 <1502117991.6577.13.camel@redhat.com>
 <20170810130531.GS23863@dhcp22.suse.cz>
 <CAAF6GDc2hsj-XJj=Rx2ZF6Sh3Ke6nKewABXfqQxQjfDd5QN7Ug@mail.gmail.com>
 <20170810153639.GB23863@dhcp22.suse.cz>
 <CAAF6GDeno6RpHf1KORVSxUL7M-CQfbWFFdyKK8LAWd_6PcJ55Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAAF6GDeno6RpHf1KORVSxUL7M-CQfbWFFdyKK8LAWd_6PcJ55Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colm =?iso-8859-1?Q?MacC=E1rthaigh?= <colm@allcosts.net>
Cc: Florian Weimer <fweimer@redhat.com>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Rik van Riel <riel@redhat.com>, Will Drewry <wad@chromium.org>, akpm@linux-foundation.org, dave.hansen@intel.com, kirill@shutemov.name, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, luto@amacapital.net, mingo@kernel.org

On Thu 10-08-17 16:17:18, Colm MacCA!rthaigh wrote:
> On DA(C)ar 10 LAon 2017 at 17:36 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Thu 10-08-17 15:23:05, Colm MacCA?rthaigh wrote:
> > > On Thu, Aug 10, 2017 at 3:05 PM, Michal Hocko <mhocko@kernel.org> wrote:
> > > >> Too late for that. VM_DONTFORK is already implemented
> > > >> through MADV_DONTFORK & MADV_DOFORK, in a way that is
> > > >> very similar to the MADV_WIPEONFORK from these patches.
> > > >
> > > > Yeah, those two seem to be breaking the "madvise as an advise"
> > semantic as
> > > > well but that doesn't mean we should follow that pattern any further.
> > >
> > > I would imagine that many of the crypto applications using
> > > MADV_WIPEONFORK will also be using MADV_DONTDUMP. In cases where it's
> > > for protecting secret keys, I'd like to use both in my code, for
> > > example. Though that doesn't really help decide this.
> > >
> > > There is also at least one case for being able to turn WIPEONFORK
> > > on/off with an existing page; a process that uses privilege separation
> > > often goes through the following flow:
> > >
> > > 1. [ Access privileged keys as a power user and initialize memory ]
> > > 2. [ Fork a child process that actually does the work ]
> > > 3. [ Child drops privileges and uses the memory to do work ]
> > > 4. [ Parent hangs around to re-spawn a child if it crashes ]
> > >
> > > In that mode it would be convenient to be able to mark the memory as
> > > WIPEONFORK in the child, but not the parent.
> >
> > I am not sure I understand. The child will have an own VMA so chaging
> > the attribute will not affect parent. Or did I misunderstand your
> > example?
> >
> 
> Typically with privilege separation the parent has to share some minimal
> state with the child. In this case that's why the page is left alone.
> Though a smart parent could unset and set just immediately around the fork.
> 
> The point then of protecting it in the child is to ensure that a grandchild
> doesn't inherit the secret data.

Does anybody actually do that using the minherit BSD interface?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
