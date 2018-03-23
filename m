Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 040056B0023
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 20:50:21 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id h89so6792039qtd.18
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 17:50:20 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 129si5186624qki.431.2018.03.22.17.50.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Mar 2018 17:50:19 -0700 (PDT)
Date: Thu, 22 Mar 2018 20:50:17 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 04/15] mm/hmm: unregister mmu_notifier when last HMM
 client quit v2
Message-ID: <20180323005017.GB5011@redhat.com>
References: <20180320020038.3360-5-jglisse@redhat.com>
 <20180321181614.9968-1-jglisse@redhat.com>
 <a9ba54c5-a2d9-49f6-16ad-46b79525b93c@nvidia.com>
 <20180321234110.GK3214@redhat.com>
 <cbc9dcba-0707-e487-d360-f6f7c8d5cb23@nvidia.com>
 <20180322233715.GA5011@redhat.com>
 <b858d92a-3a38-bfff-fe66-697c64ea2053@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <b858d92a-3a38-bfff-fe66-697c64ea2053@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>

On Thu, Mar 22, 2018 at 05:13:14PM -0700, John Hubbard wrote:
> On 03/22/2018 04:37 PM, Jerome Glisse wrote:
> > On Thu, Mar 22, 2018 at 03:47:16PM -0700, John Hubbard wrote:
> >> On 03/21/2018 04:41 PM, Jerome Glisse wrote:
> >>> On Wed, Mar 21, 2018 at 04:22:49PM -0700, John Hubbard wrote:
> >>>> On 03/21/2018 11:16 AM, jglisse@redhat.com wrote:
> >>>>> From: Jerome Glisse <jglisse@redhat.com>
> 
> <snip>
> 
> >>>
> >>> No this code is correct. hmm->mm is set after hmm struct is allocated
> >>> and before it is public so no one can race with that. It is clear in
> >>> hmm_mirror_unregister() under the write lock hence checking it here
> >>> under that same lock is correct.
> >>
> >> Are you implying that code that calls hmm_mirror_register() should do 
> >> it's own locking, to prevent simultaneous calls to that function? Because
> >> as things are right now, multiple threads can arrive at this point. The
> >> fact that mirror->hmm is not "public" is irrelevant; what matters is that
> >>> 1 thread can change it simultaneously.
> > 
> > The content of struct hmm_mirror should not be modified by code outside
> > HMM after hmm_mirror_register() and before hmm_mirror_unregister(). This
> > is a private structure to HMM and the driver should not touch it, ie it
> > should be considered as read only/const from driver code point of view.
> 
> Yes, that point is clear and obvious.
> 
> > 
> > It is also expected (which was obvious to me) that driver only call once
> > and only once hmm_mirror_register(), and only once hmm_mirror_unregister()
> > for any given hmm_mirror struct. Note that driver can register multiple
> > _different_ mirror struct to same mm or differents mm.
> > 
> > There is no need of locking on the driver side whatsoever as long as the
> > above rules are respected. I am puzzle if they were not obvious :)
> 
> Those rules were not obvious. It's unusual to claim that register and unregister
> can run concurrently, but regiser and register cannot. Let's please document
> the rules a bit in the comments.

I am really surprise this was not obvious. All existing _register API
in the kernel follow this. You register something once only and doing
it twice for same structure (ie unique struct hmm_mirror *mirror pointer
value) leads to serious bugs (doing so concurently or not).

For instance if you call mmu_notifier_register() twice (concurrently
or not) with same pointer value for struct mmu_notifier *mn then bad
thing will happen. Same for driver_register() but this one actualy
have sanity check and complain loudly if that happens. I doubt there
is any single *_register/unregister() in the kernel that does not
follow this.

Note that doing register/unregister concurrently for the same unique
hmm_mirror struct is also illegal. However concurrent register and
unregister of different hmm_mirror struct is legal and this is the
reasons for races we were discussing.

Cheers,
Jerome
