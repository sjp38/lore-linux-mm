Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 15EC58E0033
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 16:15:42 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id 80so16976126qkd.0
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 13:15:42 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r1si6020182qkk.116.2018.12.17.13.15.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 13:15:40 -0800 (PST)
Date: Mon, 17 Dec 2018 16:15:33 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181217211533.GE3341@redhat.com>
References: <20181214154321.GF8896@quack2.suse.cz>
 <20181216215819.GC10644@dastard>
 <20181217181148.GA3341@redhat.com>
 <20181217183443.GO10600@bombadil.infradead.org>
 <20181217194759.GB3341@redhat.com>
 <20181217195150.GP10600@bombadil.infradead.org>
 <20181217195408.GC3341@redhat.com>
 <20181217195922.GQ10600@bombadil.infradead.org>
 <20181217205500.GD3341@redhat.com>
 <20181217210358.GR10600@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181217210358.GR10600@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Mon, Dec 17, 2018 at 01:03:58PM -0800, Matthew Wilcox wrote:
> On Mon, Dec 17, 2018 at 03:55:01PM -0500, Jerome Glisse wrote:
> > On Mon, Dec 17, 2018 at 11:59:22AM -0800, Matthew Wilcox wrote:
> > > On Mon, Dec 17, 2018 at 02:54:08PM -0500, Jerome Glisse wrote:
> > > > On Mon, Dec 17, 2018 at 11:51:51AM -0800, Matthew Wilcox wrote:
> > > > > On Mon, Dec 17, 2018 at 02:48:00PM -0500, Jerome Glisse wrote:
> > > > > > On Mon, Dec 17, 2018 at 10:34:43AM -0800, Matthew Wilcox wrote:
> > > > > > > No.  The solution John, Dan & I have been looking at is to take the
> > > > > > > dirty page off the LRU while it is pinned by GUP.  It will never be
> > > > > > > found for writeback.
> > > > > > 
> > > > > > With the solution you are proposing we loose GUP fast and we have to
> > > > > > allocate a structure for each page that is under GUP, and the LRU
> > > > > > changes too. Moreover by not writing back there is a greater chance
> > > > > > of data loss.
> > > > > 
> > > > > Why can't you store the hmm_data in a side data structure?  Why does it
> > > > > have to be in struct page?
> > > > 
> > > > hmm_data is not even the issue here, we can have a pincount without
> > > > moving things around. So i do not see the need to complexify any of
> > > > the existing code to add new structure and consume more memory for
> > > > no good reasons. I do not see any benefit in that.
> > > 
> > > You said "we have to allocate a structure for each page that is under
> > > GUP".  The only reason to do that is if we want to keep hmm_data in
> > > struct page.  If we ditch hmm_data, there's no need to allocate a
> > > structure, and we don't lose GUP fast either.
> > 
> > And i have propose a way that do not need to ditch hmm_data nor
> > needs to remove page from the lru. What is it you do not like
> > with that ?
> 
> I don't like bounce buffering.  I don't like "end of writeback doesn't
> mark page as clean".  I don't like pages being on the LRU that aren't
> actually removable.  I don't like writing pages back which we know we're
> going to have to write back again.

And my solution allow to pick at which ever point ... you can decide to
abort write back if you feel it is better, you can remove from LRU on
first write back abort ... So you can do everything you want in my solution
it is as flexible. Right now i am finishing couple patchset once i am
done i will do an RFC on that, in my RFC i will keep write back and
bounce but it can easily be turn into no write back and remove from
LRU. My feeling is that not writing back means data loss, at the same
time if the page is on continuous write one can argue that what ever
snapshot we write back might be pointless. I do not see any strong
argument either ways.

Cheers.
J�r�me
