Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 823589003CD
	for <linux-mm@kvack.org>; Mon,  3 Aug 2015 07:56:55 -0400 (EDT)
Received: by qgeu79 with SMTP id u79so86406423qge.1
        for <linux-mm@kvack.org>; Mon, 03 Aug 2015 04:56:55 -0700 (PDT)
Received: from mail-qg0-x233.google.com (mail-qg0-x233.google.com. [2607:f8b0:400d:c04::233])
        by mx.google.com with ESMTPS id j80si16725179qge.24.2015.08.03.04.56.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Aug 2015 04:56:54 -0700 (PDT)
Received: by qgeh16 with SMTP id h16so85859625qge.3
        for <linux-mm@kvack.org>; Mon, 03 Aug 2015 04:56:53 -0700 (PDT)
Date: Mon, 3 Aug 2015 07:56:44 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 05/15] HMM: introduce heterogeneous memory management v4.
Message-ID: <20150803115643.GA2981@gmail.com>
References: <1437159145-6548-1-git-send-email-jglisse@redhat.com>
 <1437159145-6548-6-git-send-email-jglisse@redhat.com>
 <CAKrE-Kf6e19-KfUkr9nLV1DFbGQCnzGZ49iEVUbm2LVbHFmLtg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAKrE-Kf6e19-KfUkr9nLV1DFbGQCnzGZ49iEVUbm2LVbHFmLtg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Girish KS <girishks2000@gmail.com>
Cc: =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Christophe Harle <charle@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Dave Airlie <airlied@redhat.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Jatin Kumar <jakumar@nvidia.com>, joro@8bytes.org, Greg Stoner <Greg.Stoner@amd.com>, akpm@linux-foundation.org, Cameron Buschardt <cabuschardt@nvidia.com>, Rik van Riel <riel@redhat.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Lucien Dunning <ldunning@nvidia.com>, Johannes Weiner <jweiner@redhat.com>, Haggai Eran <haggaie@mellanox.com>, Michael Mantor <Michael.Mantor@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Larry Woodman <lwoodman@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Brendan Conoboy <blc@redhat.com>, John Bridgman <John.Bridgman@amd.com>, Subhash Gutti <sgutti@nvidia.com>, Roland Dreier <roland@purestorage.com>, Duncan Poole <dpoole@nvidia.com>, linux-mm@kvack.org, Alexander Deucher <Alexander.Deucher@amd.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Sherry Cheung <SCheung@nvidia.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Ben Sander <ben.sander@amd.com>, Joe Donohue <jdonohue@redhat.com>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, ks.giri@samsung.com

On Mon, Aug 03, 2015 at 01:20:13PM +0530, Girish KS wrote:
> On 18-Jul-2015 12:47 am, "Jerome Glisse" <jglisse@redhat.com> wrote:
> >

[...]

> > +int hmm_mirror_register(struct hmm_mirror *mirror)
> > +{
> > +       struct mm_struct *mm = current->mm;
> > +       struct hmm *hmm = NULL;
> > +       int ret = 0;
> > +
> > +       /* Sanity checks. */
> > +       BUG_ON(!mirror);
> > +       BUG_ON(!mirror->device);
> > +       BUG_ON(!mm);
> > +
> > +       /*
> > +        * Initialize the mirror struct fields, the mlist init and del
> dance is
> > +        * necessary to make the error path easier for driver and for hmm.
> > +        */
> > +       kref_init(&mirror->kref);
> > +       INIT_HLIST_NODE(&mirror->mlist);
> > +       INIT_LIST_HEAD(&mirror->dlist);
> > +       spin_lock(&mirror->device->lock);
> > +       list_add(&mirror->dlist, &mirror->device->mirrors);
> > +       spin_unlock(&mirror->device->lock);
> > +
> > +       down_write(&mm->mmap_sem);
> > +
> > +       hmm = mm->hmm ? hmm_ref(hmm) : NULL;
> 
> Instead of hmm mm->hmm would be the right param to be passed.  Here even
> though mm->hmm is true hmm_ref returns NULL. Because hmm is not updated
> after initialization in the beginning.

ENOPARSE ? While this can be simplified to hmm = hmm_ref(mm->hmm); I do not
see what you mean. The mm struct might already have a valid hmm field set,
and that valid hmm struct might also already be in the process of being
destroy. So hmm_ref() might either return the same hmm pointer if the hmm
object is not about to be release or NULL. But at this point there is no
certainty on the return value of hmm_ref().

Note that because we have the mmap sem in write mode we know it is safe
to dereference mm->hmm and even to overwrite that field it if it is being
destroy concurently.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
