Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1DE06C10F07
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 18:03:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DBBAC20880
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 18:03:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DBBAC20880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 65FA48E002A; Wed, 20 Feb 2019 13:03:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 60F2E8E0002; Wed, 20 Feb 2019 13:03:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4FD318E002A; Wed, 20 Feb 2019 13:03:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0E28C8E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 13:03:00 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id b12so7151319pgj.7
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 10:03:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=vTd0H+RVAnb2ymTxlDq2vbImFb/THbfRSKn13i1XQYE=;
        b=W1Dk7iBq3HPOCLu46L3Ha8Xw5qXaQPkCwNm2VdCpBMElvyjzNnfbJIrEfFLbkPjFcp
         5q3nhuwVN6xrVE/rTV5QAy97WNMkDZ/YhqHVrAHgofzDyvx9amj14eyIc3qzkMypiGZQ
         jHR3Fml7sYIPxVDQCYX3AWafl/h+ocKQJAvh/DZObFDZNy4yW+F41vCyp4T+DYuUBaiz
         UkF4hZMzdMsHwN9P7IhJ5Y7NBbZfXFaeMLjtRmcfooH1gMLWNFsmcEtILymblOo9HSrZ
         x+5YgwnExo2CoQuJQ3m77zyD/r0uDUFaYEbcPLfv9rEgVVqYK7NMQUk44l1Tm7cQXRRK
         wfyw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuYeyvoNLblC2tZ0/1GRf8lBHJGVcMieS2SWcIduJOnrha4XZpNF
	VXg9QIE1qSQDbbhB+IUJhowKZyrcXVpRmS/8wnjtWrgycMredXq5P5LuYVXf4EFWbeqq9egFywg
	gLGFTTphjsHAnaP4YK5YUYnSgyMXi6E3/78YmPiKbWAwm8JAnBlodVd5XCkEx6XtyVg==
X-Received: by 2002:a62:48c1:: with SMTP id q62mr32623997pfi.113.1550685779543;
        Wed, 20 Feb 2019 10:02:59 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaaJ6vFb1+7YQgMWghUrFWKSK97orUZg7GX5WU2uVyxXaOGUbj7tNcl4FKYLTbhoxZDuCBp
X-Received: by 2002:a62:48c1:: with SMTP id q62mr32623939pfi.113.1550685778672;
        Wed, 20 Feb 2019 10:02:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550685778; cv=none;
        d=google.com; s=arc-20160816;
        b=te0k/8XtrdbAarbGe5zsK3tPs1rSqfAHsnlJoqwdd+DUe+58dMr/v3udbxNGGwA906
         +FyjJ4/4bs0k000NFkEmCtaqk+SaV8SkPf7RMRJIJhbv5QztEwjce6Q23JZgyv5zuOgy
         tZfMqu7vVx7MnJxGdMFLOQgd8INZxNVlPWITWufgLUr0d8iNsEUQNK0FYc3EN8ot6q/L
         tceidyMJmb9a+bo5ZBV9K/BgGtoJLy/y+6p1Sl/yyclmO+alJO+W5nXqqRaAgzWx50Ml
         25WIx2fa5fIPgyA9IcTeBtJCGbMMwFhNJziSyOsZ8wXGaZSpnNYdtjqZ06Ch7zr4+5oJ
         2zXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=vTd0H+RVAnb2ymTxlDq2vbImFb/THbfRSKn13i1XQYE=;
        b=cZFq5H+WvGDU71BnW6AlAJ1PaRB8QjFbjY5x9MXZfHAjaHNhXtGj3UCobsvlW3BX2i
         23CuoxQfF1uA5ZGYO2dSzTECcZtgouOqp7objadnzjOiULsMDokejyWDBbbLZr8BNcKW
         PIhJEk/ZUMzSUpnX+7aD62I+9M/zjhy58UrV0FeMGxM+B2WtZaqgZwP89mqSBKXyKkxH
         ZtXci5HYr9qHkIUHcc+//iBQLS0P9mbY6BnkcJhIqvDrWzdNs/wD3xrUEcV1SzmT3wB5
         gL/IR3cHcQU52cyaQw8JsaUu+UqieM1RfMcPJpCYp2QSI53z7o/BsrrYnw4McxYu9MFp
         Rdvw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id z186si5906294pgd.477.2019.02.20.10.02.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 10:02:57 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 20 Feb 2019 10:02:55 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,391,1544515200"; 
   d="scan'208";a="148440466"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga001.fm.intel.com with ESMTP; 20 Feb 2019 10:02:55 -0800
Date: Wed, 20 Feb 2019 10:02:56 -0800
From: Ira Weiny <ira.weiny@intel.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: John Hubbard <jhubbard@nvidia.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Rich Felker <dalias@libc.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org, kvm-ppc@vger.kernel.org,
	kvm@vger.kernel.org, linux-fpga@vger.kernel.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, linux-scsi@vger.kernel.org,
	devel@driverdev.osuosl.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-fbdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	devel@lists.orangefs.org, ceph-devel@vger.kernel.org,
	rds-devel@oss.oracle.com
Subject: Re: [RESEND PATCH 0/7] Add FOLL_LONGTERM to GUP fast and use it
Message-ID: <20190220180255.GA12020@iweiny-DESK2.sc.intel.com>
References: <20190220053040.10831-1-ira.weiny@intel.com>
 <20190220151930.GB11695@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190220151930.GB11695@infradead.org>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2019 at 07:19:30AM -0800, Christoph Hellwig wrote:
> On Tue, Feb 19, 2019 at 09:30:33PM -0800, ira.weiny@intel.com wrote:
> > From: Ira Weiny <ira.weiny@intel.com>
> > 
> > Resending these as I had only 1 minor comment which I believe we have covered
> > in this series.  I was anticipating these going through the mm tree as they
> > depend on a cleanup patch there and the IB changes are very minor.  But they
> > could just as well go through the IB tree.
> > 
> > NOTE: This series depends on my clean up patch to remove the write parameter
> > from gup_fast_permitted()[1]
> > 
> > HFI1, qib, and mthca, use get_user_pages_fast() due to it performance
> > advantages.  These pages can be held for a significant time.  But
> > get_user_pages_fast() does not protect against mapping of FS DAX pages.
> 
> This I don't get - if you do lock down long term mappings performance
> of the actual get_user_pages call shouldn't matter to start with.
> 
> What do I miss?

A couple of points.

First "longterm" is a relative thing and at this point is probably a misnomer.
This is really flagging a pin which is going to be given to hardware and can't
move.  I've thought of a couple of alternative names but I think we have to
settle on if we are going to use FL_LAYOUT or something else to solve the
"longterm" problem.  Then I think we can change the flag to a better name.

Second, It depends on how often you are registering memory.  I have spoken with
some RDMA users who consider MR in the performance path...  For the overall
application performance.  I don't have the numbers as the tests for HFI1 were
done a long time ago.  But there was a significant advantage.  Some of which is
probably due to the fact that you don't have to hold mmap_sem.

Finally, architecturally I think it would be good for everyone to use *_fast.
There are patches submitted to the RDMA list which would allow the use of
*_fast (they reworking the use of mmap_sem) and as soon as they are accepted
I'll submit a patch to convert the RDMA core as well.  Also to this point
others are looking to use *_fast.[2]

As an asside, Jasons pointed out in my previous submission that *_fast and
*_unlocked look very much the same.  I agree and I think further cleanup will
be coming.  But I'm focused on getting the final solution for DAX at the
moment.

Ira

