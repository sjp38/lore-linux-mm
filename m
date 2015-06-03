Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 87FA0900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 19:02:06 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so17126409pdb.0
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 16:02:06 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id bo16si2974229pdb.32.2015.06.03.16.02.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 03 Jun 2015 16:02:05 -0700 (PDT)
Date: Wed, 3 Jun 2015 16:02:02 -0700
From: John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH 01/36] mmu_notifier: add event information to address
 invalidation v7
In-Reply-To: <20150603160711.GA2602@gmail.com>
Message-ID: <alpine.LNX.2.03.1506031555440.980@nvidia.com>
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com> <1432236705-4209-2-git-send-email-j.glisse@gmail.com> <alpine.LNX.2.03.1505292001580.13637@nvidia.com> <20150601190331.GA4170@gmail.com> <alpine.LNX.2.03.1506011525460.17506@nvidia.com>
 <20150603160711.GA2602@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="279739828-1836793317-1433372523=:980"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron
 Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent
 Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?ISO-8859-15?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>

--279739828-1836793317-1433372523=:980
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT

On Wed, 3 Jun 2015, Jerome Glisse wrote:
> On Mon, Jun 01, 2015 at 04:10:46PM -0700, John Hubbard wrote:
> > On Mon, 1 Jun 2015, Jerome Glisse wrote:
> > > On Fri, May 29, 2015 at 08:43:59PM -0700, John Hubbard wrote:
> > > > On Thu, 21 May 2015, j.glisse@gmail.com wrote:
> > > > > From: Jerome Glisse <jglisse@redhat.com>
> 
> [...]
> > > > We may have to add MMU_READ_WRITE (and maybe another one, I haven't 
> > > > bottomed out on that), if you agree with the above approach of 
> > > > always sending a precise event, instead of "protection changed".
> > > 
> > > I think Linus point made sense last time, but i would need to read
> > > again the thread. The idea of that patch is really to provide context
> > > information on what kind of CPU page table changes is happening and
> > > why.
> > >
> > 
> > Shoot, I tried to find that conversation, but my search foo is too weak. 
> > If you have a link to that thread, I'd appreciate it, so I can refresh my 
> > memory.
> > 
> > I was hoping to re-read it and see if anything has changed. It's not 
> > really a huge problem to call find_vma() again, but I do want to be sure 
> > that there's a good reason for doing so.
> >  
> > Otherwise, I'll just rely on your memory that Linus preferred your current 
> > approach, and call it good, then.
> 
> http://lkml.iu.edu/hypermail/linux/kernel/1406.3/04880.html
> 
> I am working on doing some of the changes discussed so far, i will push my
> tree to git://people.freedesktop.org/~glisse/linux hmm branch once i am done.


Aha, OK, that was back when you were passing around the vma. But now, 
you're not doing that anymore. It's just: mm*, range* (start, end, 
event_type), and sometimes page* and exclude*). So I think it's still 
reasonable to either pass down pure vma flags, or else add in new event 
types, in order to avoid having to lookup the vma later.

We could still get NAK'd for adding ugly new event types, but if you're 
going to add the event types at all, let's make them complete, so that we 
really *earn* the NAK. :)

> 
> Cheers,
> Jerome
> 

--279739828-1836793317-1433372523=:980--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
