Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id EDA3A6B000D
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 12:44:12 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id b17-v6so3455671pfo.20
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 09:44:12 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b34-v6si1323274plc.428.2018.10.03.09.44.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 09:44:10 -0700 (PDT)
Date: Wed, 3 Oct 2018 18:44:07 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: Problems with VM_MIXEDMAP removal from /proc/<pid>/smaps
Message-ID: <20181003164407.GK24030@quack2.suse.cz>
References: <20181002142959.GD9127@quack2.suse.cz>
 <20181002143713.GA19845@infradead.org>
 <20181002144412.GC4963@linux-x5ow.site>
 <20181002145206.GA10903@infradead.org>
 <20181002153100.GG9127@quack2.suse.cz>
 <CAPcyv4j0tTD+rENqFExA68aw=-MmtCBaOe1qJovyrmJC=yBg-Q@mail.gmail.com>
 <20181003125056.GA21043@quack2.suse.cz>
 <CAPcyv4jfV10yuTiPg6ijsPRRL2-c_48ovfpU5TK1Zu7BWnfk3g@mail.gmail.com>
 <20181003150658.GC24030@quack2.suse.cz>
 <CAPcyv4iJvN6_Cf6tw=5a=Uh99LfMFKU7n8QkGcz1ZaxL0Oi-3w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4iJvN6_Cf6tw=5a=Uh99LfMFKU7n8QkGcz1ZaxL0Oi-3w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, Johannes Thumshirn <jthumshirn@suse.de>, Dave Jiang <dave.jiang@intel.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-xfs <linux-xfs@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Wed 03-10-18 08:13:37, Dan Williams wrote:
> On Wed, Oct 3, 2018 at 8:07 AM Jan Kara <jack@suse.cz> wrote:
> > WRT per-inode DAX property, AFAIU that inode flag is just going to be
> > advisory thing - i.e., use DAX if possible. If you mount a filesystem with
> > these inode flags set in a configuration which does not allow DAX to be
> > used, you will still be able to access such inodes but the access will use
> > page cache instead. And querying these flags should better show real
> > on-disk status and not just whether DAX is used as that would result in an
> > even bigger mess. So this feature seems to be somewhat orthogonal to the
> > API I'm looking for.
> 
> True, I imagine once we have that flag we will be able to distinguish
> the "saved" property and the "effective / live" property of DAX...
> Also it's really not DAX that applications care about as much as "is
> there page-cache indirection / overhead for this mapping?". That seems
> to be a narrower guarantee that we can make than what "DAX" might
> imply.

Right. So what do people think about my suggestion earlier in the thread to
use madvise(MADV_DIRECT_ACCESS) for this? Currently it would return success
when DAX is in use, failure otherwise. Later we could extend it to be also
used as a hint for caching policy for the inode...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
