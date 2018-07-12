Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4DA356B0003
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 15:57:20 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id t10-v6so19177846pfh.0
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 12:57:20 -0700 (PDT)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id o3-v6si22441758plk.321.2018.07.12.12.57.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 12 Jul 2018 12:57:18 -0700 (PDT)
Message-ID: <1531425435.18255.17.camel@HansenPartnership.com>
Subject: Re: [PATCH v6 0/7] fs/dcache: Track & limit # of negative dentries
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Thu, 12 Jul 2018 12:57:15 -0700
In-Reply-To: <CA+55aFzfQz7c8pcMfLDaRNReNF2HaKJGoWpgB6caQjNAyjg-hA@mail.gmail.com>
References: <62275711-e01d-7dbe-06f1-bf094b618195@redhat.com>
	 <20180710142740.GQ14284@dhcp22.suse.cz>
	 <a2794bcc-9193-cbca-3a54-47420a2ab52c@redhat.com>
	 <20180711102139.GG20050@dhcp22.suse.cz>
	 <9f24c043-1fca-ee86-d609-873a7a8f7a64@redhat.com>
	 <1531330947.3260.13.camel@HansenPartnership.com>
	 <18c5cbfe-403b-bb2b-1d11-19d324ec6234@redhat.com>
	 <1531336913.3260.18.camel@HansenPartnership.com>
	 <4d49a270-23c9-529f-f544-65508b6b53cc@redhat.com>
	 <1531411494.18255.6.camel@HansenPartnership.com>
	 <20180712164932.GA3475@bombadil.infradead.org>
	 <1531416080.18255.8.camel@HansenPartnership.com>
	 <CA+55aFzfQz7c8pcMfLDaRNReNF2HaKJGoWpgB6caQjNAyjg-hA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, Waiman Long <longman@redhat.com>, Michal Hocko <mhocko@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "open
 list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Jan Kara <jack@suse.cz>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Larry Woodman <lwoodman@redhat.com>, "Wangkai
 (Kevin,C)" <wangkai86@huawei.com>

On Thu, 2018-07-12 at 11:06 -0700, Linus Torvalds wrote:
> On Thu, Jul 12, 2018 at 10:21 AM James Bottomley
> <James.Bottomley@hansenpartnership.com> wrote:
> > 
> > On Thu, 2018-07-12 at 09:49 -0700, Matthew Wilcox wrote:
> > > 
> > > I don't know that it does work.A A Or that it works well.
> > 
> > I'm not claiming the general heuristics are perfect (in fact I know
> > we
> > still have a lot of problems with dirty reclaim and writeback).
> 
> I think this whole "this is about running out of memory" approach is
> wrong.
> 
> We *should* handle that well. Or well enough in practice, at least.
> 
> Do we? Maybe not. Should the dcache be the one area to be policed and
> worked around? Probably not.
> 
> But there may be other reasons to just limit negative dentries.
> 
> What does the attached program do to people? It's written to be
> intentionally annoying to the dcache.

So it's interesting.  What happens for me is that I start out at pretty
much no free memory so the programme slowly starts to fill up my
available swap without shrinking my page cache (presumably it's causing
dirty anonymous objects to be pushed out) and the dcache grows a bit.
Then when my free swap reaches 0 we start to reclaim the dcache and it
shrinks again (apparently still keeping the page cache at around 1.8G).
 The system seems perfectly usable while this is running (tried browser
and a couple of compiles) ... any calls for free memory seem to come
out of the enormous but easily reclaimable dcache.

The swap effect is unexpected, but everything else seems to be going
according to how I would wish.

When I kill the programme I get about a megabyte of swap back but it's
staying with the rest of swap occupied.  When all this started I had an
8G laptop with 2G of swap of which 1G was used.  Now I have 2G of swap
used but it all seems to be running OK.

So what I mean by dcache grows a bit is this:

I missed checking it before I started, but it eventually grew to

jejb@jarvis:~> cat /proc/sys/fs/dentry-stateA 
2841534	2816297	45	0	0	0

Before eventually going back after I killed the programme to

jejb@jarvis:~> cat /proc/sys/fs/dentry-stateA 
806559	781138	45	0	0	0

I just tried it again and this time the dcache only peaked at 

jejb@jarvis:~> cat /proc/sys/fs/dentry-stateA 
2321933	2296607	45	0	0	0

What surprises me most about this behaviour is the steadiness of the
page cache ... I would have thought we'd have shrunk it somewhat given
the intense call on the dcache.

James
