Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id 5D45C6B0253
	for <linux-mm@kvack.org>; Tue,  4 Aug 2015 10:17:12 -0400 (EDT)
Received: by qkdv3 with SMTP id v3so3618894qkd.3
        for <linux-mm@kvack.org>; Tue, 04 Aug 2015 07:17:12 -0700 (PDT)
Received: from mail-qk0-x232.google.com (mail-qk0-x232.google.com. [2607:f8b0:400d:c09::232])
        by mx.google.com with ESMTPS id d185si2008213qhc.54.2015.08.04.07.17.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Aug 2015 07:17:11 -0700 (PDT)
Received: by qkdg63 with SMTP id g63so3642763qkd.0
        for <linux-mm@kvack.org>; Tue, 04 Aug 2015 07:17:10 -0700 (PDT)
Date: Tue, 4 Aug 2015 10:17:02 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: Re: [PATCH 05/15] HMM: introduce heterogeneous memory management
 v4.
Message-ID: <20150804141701.GA3511@gmail.com>
References: <359230388.367691438604474011.JavaMail.weblogic@epmlwas08c>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <359230388.367691438604474011.JavaMail.weblogic@epmlwas08c>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: GIRISH K S <ks.giri@samsung.com>
Cc: Girish KS <girishks2000@gmail.com>, J??e Glisse <jglisse@redhat.com>, Christophe Harle <charle@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Dave Airlie <airlied@redhat.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Jatin Kumar <jakumar@nvidia.com>, "joro@8bytes.org" <joro@8bytes.org>, Greg Stoner <Greg.Stoner@amd.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Cameron Buschardt <cabuschardt@nvidia.com>, Rik van Riel <riel@redhat.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Lucien Dunning <ldunning@nvidia.com>, Johannes Weiner <jweiner@redhat.com>, Haggai Eran <haggaie@mellanox.com>, Michael Mantor <Michael.Mantor@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Larry Woodman <lwoodman@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Brendan Conoboy <blc@redhat.com>, John Bridgman <John.Bridgman@amd.com>, Subhash Gutti <sgutti@nvidia.com>, Roland Dreier <roland@purestorage.com>, Duncan Poole <dpoole@nvidia.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Alexander Deucher <Alexander.Deucher@amd.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Sherry Cheung <SCheung@nvidia.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Ben Sander <ben.sander@amd.com>, Joe Donohue <jdonohue@redhat.com>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>

On Mon, Aug 03, 2015 at 12:21:14PM +0000, GIRISH K S wrote:
> On Mon, Aug 03, 2015 at 01:20:13PM +0530, Girish KS wrote:
> > On 18-Jul-2015 12:47 am, "JA?AE?A?A?A?a??A?A?A?a??A?A 1/2 A?AE?A?A?A?a??A?A?A?a??A?A 1/2 e Glisse" wrote:
> > >
> 
> [...]
> 
> > > +int hmm_mirror_register(struct hmm_mirror *mirror)
> > > +{
> > > +       struct mm_struct *mm = current->mm;
> > > +       struct hmm *hmm = NULL;
> > > +       int ret = 0;
> > > +
> > > +       /* Sanity checks. */
> > > +       BUG_ON(!mirror);
> > > +       BUG_ON(!mirror->device);
> > > +       BUG_ON(!mm);
> > > +
> > > +       /*
> > > +        * Initialize the mirror struct fields, the mlist init and del
> > dance is
> > > +        * necessary to make the error path easier for driver and for hmm.
> > > +        */
> > > +       kref_init(&mirror->kref);
> > > +       INIT_HLIST_NODE(&mirror->mlist);
> > > +       INIT_LIST_HEAD(&mirror->dlist);
> > > +       spin_lock(&mirror->device->lock);
> > > +       list_add(&mirror->dlist, &mirror->device->mirrors);
> > > +       spin_unlock(&mirror->device->lock);
> > > +
> > > +       down_write(&mm->mmap_sem);
> > > +
> > > +       hmm = mm->hmm ? hmm_ref(hmm) : NULL;
> > 
> > Instead of hmm mm->hmm would be the right param to be passed.  Here even
> > though mm->hmm is true hmm_ref returns NULL. Because hmm is not updated
> > after initialization in the beginning.
> 
> ENOPARSE ? While this can be simplified to hmm = hmm_ref(mm->hmm); I do not
> see what you mean. The mm struct might already have a valid hmm field set,
> and that valid hmm struct might also already be in the process of being
> destroy. So hmm_ref() might either return the same hmm pointer if the hmm
> object is not about to be release or NULL. But at this point there is no
> certainty on the return value of hmm_ref().
> 
> I didn't mean hmm = hmm_ref(mm->hmm);. I ll try to put it in a better way.
> The hmm local variable is initialized to NULL in the start of the function
> (struct hmm *hmm = NULL;), and this is not modified till it is passed to
> hmm_ref.  So hmm_ref would always return a NULL irrespective of mm->hmm is
> NULL or valid address.  
> So  the statement hmm = mm->hmm ? hmm_ref(hmm) : NULL; should be replaced
> as hmm = mm->hmm ? hmm_ref(mm->hmm) : NULL;. 

Oh yeah typo probably outcome of many patch reorg i did.

Cheers,
JA(C)rA'me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
