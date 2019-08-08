Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9D25C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 02:36:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 433C7216C8
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 02:36:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 433C7216C8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F8FB6B0006; Wed,  7 Aug 2019 22:36:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8826C6B0008; Wed,  7 Aug 2019 22:36:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 723DE6B000A; Wed,  7 Aug 2019 22:36:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 375A46B0006
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 22:36:42 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 145so58061448pfw.16
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 19:36:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=TlLuksaShgPNjauQI9Btl3YqtA+lZG5++sUoWgVRzms=;
        b=BTcYG5+LwibMh8rkBLTS4q7C9i8NVcNmNoIuT9QkLgLL3VBz+202fn4opoRXNQc5jI
         xF8L66kgx8SGtrU9UrLCI0wYOh8cZDeOpM+Oe+o9uiplHvFvE+KclvDxAdy9fckE33Ho
         wYNs5LqrJVTuqB99m7Tl2OlckL+Lo2ZzOBFQh01si0aEKgP39V45tjgqIEZCLSOkbSfE
         EGLYvEfmJkZRaNl62Tqiu+cqj1uRK5LAHGHn/aP3AsIQoRXaVqpGXJ9YDVjOTPiPQoz4
         Izqsao3whBXxDgw8vwsD4o4a0tzPidVKaAC0/819Yer/E7teiz6pt7TNm5pS6r+P3dCD
         e7Fw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXekfM6d0ItHzaK23rr4pmOnH8ReZC6Ln+qj8D9a5dixkzRiZBA
	l8JlGLeDdaI4HP7Ow72JvNNRkBCkR8/IexjghuzZ+n2KYCaYW49EMK/E1R8fjMlzWAkafZAuBLo
	WIQWF/wwObm0gfnOReEr4jUMW/FNHdBoXS34RJJlCaz9NJbGfu/EfIWEE/Qnih/geVQ==
X-Received: by 2002:a17:90a:1aa4:: with SMTP id p33mr1559115pjp.27.1565231801825;
        Wed, 07 Aug 2019 19:36:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxRvZHfSXb4PfbVBA5yx4rBJOy89PUXIRM/UpCJy39/hjNjUn/GYH+LNffy+dJqv9JqhlGL
X-Received: by 2002:a17:90a:1aa4:: with SMTP id p33mr1559038pjp.27.1565231800608;
        Wed, 07 Aug 2019 19:36:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565231800; cv=none;
        d=google.com; s=arc-20160816;
        b=iIJ1rWtZIZB8Ni5V1J0/7bbeg9mlFmylZ75l2nmRpqPoE0rBUC50iMbgS4Mb5PQEU+
         324BxVz+w/J/+X3Y3m3w2L8SST9u5HW2+1TXdB2F/dgF6yT0MMGzRFqPeMIarjoFchmC
         AhT/28XIDz+IKTMn4DK/wXCiNehuzaJIMu70doRygYgv+6XidxQ9+325gmDgQltWqJg9
         WX1wBep+b8hTfp1BeZFumUso5I9UXBxB/OwRJRXvZYOWyENOBGzjugPUHe6UIQ6P9Jun
         BVIkjFLVRI2d4sRiqPAum9LWDpyazh8cEMbrpkFJ7iLB3GyjowNCJW9TIl0ArOgXoHYS
         Socw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=TlLuksaShgPNjauQI9Btl3YqtA+lZG5++sUoWgVRzms=;
        b=z9/aLbTiD3x8Z+TXmPfOvw5RbHvjKFnQusiDZldWtd2sF4x7+sCaCZCmr65XYkwZnk
         4nnEspbrqADeklfBF2rBrbHDq8GpNPxfA4QY8XAChIUhtiDnX8/B9mMPKhdmyMU/F6Ao
         x8JmqpJgTwYKMe+dWYa7zv8tfea23eQ4HiYtpSuxB7tyloiQSYvBPPoAsu9qT01w2AQq
         PMVippzwY/FLo22v7ufrdU/DRrO4FZtvEcMUpAI4RUADBEmrdq7fKRsP+AqbE2ZQJNtG
         qvKXl1ImJHobQkl+VfIfkVA/YWKWdcujJqn8MLf9TZYOObwbtn1W3OCmXlu+RZdHsN3l
         XzPA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id f131si47996277pgc.265.2019.08.07.19.36.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 19:36:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 Aug 2019 19:36:39 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,358,1559545200"; 
   d="scan'208";a="186207302"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga002.jf.intel.com with ESMTP; 07 Aug 2019 19:36:38 -0700
Date: Wed, 7 Aug 2019 19:36:37 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Jan Kara <jack@suse.cz>, John Hubbard <jhubbard@nvidia.com>,
	Matthew Wilcox <willy@infradead.org>, john.hubbard@gmail.com,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>, amd-gfx@lists.freedesktop.org,
	ceph-devel@vger.kernel.org, devel@driverdev.osuosl.org,
	devel@lists.orangefs.org, dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org, kvm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-block@vger.kernel.org,
	linux-crypto@vger.kernel.org, linux-fbdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-media@vger.kernel.org,
	linux-mm@kvack.org, linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-rpi-kernel@lists.infradead.org,
	linux-xfs@vger.kernel.org, netdev@vger.kernel.org,
	rds-devel@oss.oracle.com, sparclinux@vger.kernel.org,
	x86@kernel.org, xen-devel@lists.xenproject.org
Subject: Re: [PATCH 00/34] put_user_pages(): miscellaneous call sites
Message-ID: <20190808023637.GA1508@iweiny-DESK2.sc.intel.com>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
 <20190802091244.GD6461@dhcp22.suse.cz>
 <20190802124146.GL25064@quack2.suse.cz>
 <20190802142443.GB5597@bombadil.infradead.org>
 <20190802145227.GQ25064@quack2.suse.cz>
 <076e7826-67a5-4829-aae2-2b90f302cebd@nvidia.com>
 <20190807083726.GA14658@quack2.suse.cz>
 <20190807084649.GQ11812@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190807084649.GQ11812@dhcp22.suse.cz>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 07, 2019 at 10:46:49AM +0200, Michal Hocko wrote:
> On Wed 07-08-19 10:37:26, Jan Kara wrote:
> > On Fri 02-08-19 12:14:09, John Hubbard wrote:
> > > On 8/2/19 7:52 AM, Jan Kara wrote:
> > > > On Fri 02-08-19 07:24:43, Matthew Wilcox wrote:
> > > > > On Fri, Aug 02, 2019 at 02:41:46PM +0200, Jan Kara wrote:
> > > > > > On Fri 02-08-19 11:12:44, Michal Hocko wrote:
> > > > > > > On Thu 01-08-19 19:19:31, john.hubbard@gmail.com wrote:
> > > > > > > [...]
> > > > > > > > 2) Convert all of the call sites for get_user_pages*(), to
> > > > > > > > invoke put_user_page*(), instead of put_page(). This involves dozens of
> > > > > > > > call sites, and will take some time.
> > > > > > > 
> > > > > > > How do we make sure this is the case and it will remain the case in the
> > > > > > > future? There must be some automagic to enforce/check that. It is simply
> > > > > > > not manageable to do it every now and then because then 3) will simply
> > > > > > > be never safe.
> > > > > > > 
> > > > > > > Have you considered coccinele or some other scripted way to do the
> > > > > > > transition? I have no idea how to deal with future changes that would
> > > > > > > break the balance though.
> > > 
> > > Hi Michal,
> > > 
> > > Yes, I've thought about it, and coccinelle falls a bit short (it's not smart
> > > enough to know which put_page()'s to convert). However, there is a debug
> > > option planned: a yet-to-be-posted commit [1] uses struct page extensions
> > > (obviously protected by CONFIG_DEBUG_GET_USER_PAGES_REFERENCES) to add
> > > a redundant counter. That allows:
> > > 
> > > void __put_page(struct page *page)
> > > {
> > > 	...
> > > 	/* Someone called put_page() instead of put_user_page() */
> > > 	WARN_ON_ONCE(atomic_read(&page_ext->pin_count) > 0);
> > > 
> > > > > > 
> > > > > > Yeah, that's why I've been suggesting at LSF/MM that we may need to create
> > > > > > a gup wrapper - say vaddr_pin_pages() - and track which sites dropping
> > > > > > references got converted by using this wrapper instead of gup. The
> > > > > > counterpart would then be more logically named as unpin_page() or whatever
> > > > > > instead of put_user_page().  Sure this is not completely foolproof (you can
> > > > > > create new callsite using vaddr_pin_pages() and then just drop refs using
> > > > > > put_page()) but I suppose it would be a high enough barrier for missed
> > > > > > conversions... Thoughts?
> > > 
> > > The debug option above is still a bit simplistic in its implementation
> > > (and maybe not taking full advantage of the data it has), but I think
> > > it's preferable, because it monitors the "core" and WARNs.
> > > 
> > > Instead of the wrapper, I'm thinking: documentation and the passage of
> > > time, plus the debug option (perhaps enhanced--probably once I post it
> > > someone will notice opportunities), yes?
> > 
> > So I think your debug option and my suggested renaming serve a bit
> > different purposes (and thus both make sense). If you do the renaming, you
> > can just grep to see unconverted sites. Also when someone merges new GUP
> > user (unaware of the new rules) while you switch GUP to use pins instead of
> > ordinary references, you'll get compilation error in case of renaming
> > instead of hard to debug refcount leak without the renaming. And such
> > conflict is almost bound to happen given the size of GUP patch set... Also
> > the renaming serves against the "coding inertia" - i.e., GUP is around for
> > ages so people just use it without checking any documentation or comments.
> > After switching how GUP works, what used to be correct isn't anymore so
> > renaming the function serves as a warning that something has really
> > changed.
> 
> Fully agreed!

Ok Prior to this I've been basing all my work for the RDMA/FS DAX stuff in
Johns put_user_pages()...  (Including when I proposed failing truncate with a
lease in June [1])

However, based on the suggestions in that thread it became clear that a new
interface was going to need to be added to pass in the "RDMA file" information
to GUP to associate file pins with the correct processes...

I have many drawings on my white board with "a whole lot of lines" on them to
make sure that if a process opens a file, mmaps it, pins it with RDMA, _closes_
it, and ummaps it; that the resulting file pin can still be traced back to the
RDMA context and all the processes which may have access to it....  No matter
where the original context may have come from.  I believe I have accomplished
that.

Before I go on, I would like to say that the "imbalance" of get_user_pages()
and put_page() bothers me from a purist standpoint...  However, since this
discussion cropped up I went ahead and ported my work to Linus' current master
(5.3-rc3+) and in doing so I only had to steal a bit of Johns code...  Sorry
John...  :-(

I don't have the commit messages all cleaned up and I know there may be some
discussion on these new interfaces but I wanted to throw this series out there
because I think it may be what Jan and Michal are driving at (or at least in
that direction.

Right now only RDMA and DAX FS's are supported.  Other users of GUP will still
fail on a DAX file and regular files will still be at risk.[2]

I've pushed this work (based 5.3-rc3+ (33920f1ec5bf)) here[3]:

https://github.com/weiny2/linux-kernel/tree/linus-rdmafsdax-b0-v3

I think the most relevant patch to this conversation is:

https://github.com/weiny2/linux-kernel/commit/5d377653ba5cf11c3b716f904b057bee6641aaf6

I stole Jans suggestion for a name as the name I used while prototyping was
pretty bad...  So Thanks Jan...  ;-)

Also thanks to John for his contribution on some of this.  I'm still tweaking
put_user_pages under the hood on the DAX path.

Ira

[1] https://lwn.net/Articles/790544/

[2] I've been looking into how to support io_uring next but I've had some issue
getting a test program to actually call GUP in that code path...  :-(

[3] If it would be easier I can just throw an RFC on the list but right now the
cover letter and some of the commit messages are full of the old stuff and
various ideas I have had...

> 
> > Your refcount debug patches are good to catch bugs in the conversions done
> > but that requires you to be able to excercise the code path in the first
> > place which may require particular HW or so, and you also have to enable
> > the debug option which means you already aim at verifying the GUP
> > references are treated properly.
> > 
> > 								Honza
> > 
> > -- 
> > Jan Kara <jack@suse.com>
> > SUSE Labs, CR
> 
> -- 
> Michal Hocko
> SUSE Labs

