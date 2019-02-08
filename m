Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07732C169C4
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 04:43:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B861721908
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 04:43:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B861721908
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 57C638E0075; Thu,  7 Feb 2019 23:43:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 52B7C8E0002; Thu,  7 Feb 2019 23:43:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4416C8E0075; Thu,  7 Feb 2019 23:43:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 076B88E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 23:43:07 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id 202so1517689pgb.6
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 20:43:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=NGfF3SjXSF+XsniPipOZHVwea5S9QedD9GnnN2j2F5Y=;
        b=dKa0KKNBNASEHtgnPilAaGKY+UsAM9Gwyw8jtc/ijb5S/jWt0QkPvLhKYfBxQ5Bccv
         dEZ5k/LS1FyrMXCKrOrty/Tqs83crGXDdAhILlmHE9/ssuZWXsUeIAgli68eCAwIEgeU
         Hp1ACgENXUDx7c+a9aijMWf1o14o1cuelPzHv7HKVttI6z1nUFUZSkpejPWQCl4ZoCvE
         vtaeMOwt5sEkzcKmPPbtqek+8Mzg3Opx+33w+anorSB2EGsrIi1EyN9ALIgRi5ktxknq
         p3H5yua8iCeoN96Hu9HbldfPpCieXR1sfvmEOcoSCQj6YVaG5XoXH7o95xUQSkYkdDro
         UD+A==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 150.101.137.145 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: AHQUAuZVKLb47ppH8l1OmKJfNsxQ+c3sL9K7nCovfGwKf8LmVGX9WXXt
	P/zlETZKUulcKVZ7zYq7RPbld9zgBqNTOwQ1JoCcnmDqtsIzslG2xWYqkIYVEexEUFn4UQb8lgC
	+jpcjTSovMJibcXzmf9M6B7P27ereYhtjWs6YVYfNbQHnVYdSU5J421r3tPwRewQ=
X-Received: by 2002:a62:c505:: with SMTP id j5mr20103584pfg.149.1549600986649;
        Thu, 07 Feb 2019 20:43:06 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYiHWmChRkWV7XdR3zu44AZOUOPKh4pjR+hQJSGxnJEgeXNCPwBAJwMbZ2Rgm0yvij62W9N
X-Received: by 2002:a62:c505:: with SMTP id j5mr20103533pfg.149.1549600985766;
        Thu, 07 Feb 2019 20:43:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549600985; cv=none;
        d=google.com; s=arc-20160816;
        b=VLI/v9Gjj40g1nkRF638Z5MunlljdddRjrKXEVOtSRvRYBUT40wLaLivQMO8LN4wJY
         cBk8fuu+6TKYyQHw03U5ge7FOplAwsnD0mJSpPfSE19aW96Llulu5pa1lHyMF8YHsXSU
         AMnADEvuJmjjmusnXkvU7zY0KqWnO4f7QKM1u+TckXibs39aB9rsXGNfFl2nYMe4Qy71
         1zMQhIoDo9JXcFZZUV8icxAVgPTTuL//aURKHUTQ6l1vcPu5lv0GMQ9fnTFk/c2lZGi9
         qzXGflIX2Qvw+norh/6T95YSl1TNBW4SoPxHB810DdLyFvtAm7UOhMPtfyVcLWfsezI8
         fcRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=NGfF3SjXSF+XsniPipOZHVwea5S9QedD9GnnN2j2F5Y=;
        b=RSvzj34qzgkggu2c6eW92eySSL4QYRyAJJvrspjUilzdLoUQL9/ZzYwYbINTwVxvNu
         pXuBeme6u9c51cpxhlg0kkFl2F9MFX+0XcXQ7E0xhdULnL4MM1dkovcWLlSiVw7NpiDl
         p9NSN6H63jIPOO7T/magPlH9lFZR68ZAlNtojzyCD1odiikU/HFca/yDawVfsmodr5ZC
         6m6TUH9CnkBOdYhaU7jbpliuef8aXOMlcxIFup58COQhSp2vFt4TiHgOGoMdjdE4FiA6
         zxs5drWI+i9R9YMBYvKx3yEA6MVIwIy9fnOZS5RCm8bGg3XAzZgHYKzMWYWs+zcdoWcK
         0yfg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 150.101.137.145 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id t61si1193209plb.339.2019.02.07.20.43.04
        for <linux-mm@kvack.org>;
        Thu, 07 Feb 2019 20:43:05 -0800 (PST)
Received-SPF: neutral (google.com: 150.101.137.145 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=150.101.137.145;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 150.101.137.145 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail06.adl6.internode.on.net with ESMTP; 08 Feb 2019 15:13:03 +1030
Received: from dave by dastard with local (Exim 4.80)
	(envelope-from <david@fromorbit.com>)
	id 1gry0E-0005Lj-8g; Fri, 08 Feb 2019 15:43:02 +1100
Date: Fri, 8 Feb 2019 15:43:02 +1100
From: Dave Chinner <david@fromorbit.com>
To: Christopher Lameter <cl@linux.com>
Cc: Doug Ledford <dledford@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>,
	Ira Weiny <ira.weiny@intel.com>, lsf-pc@lists.linux-foundation.org,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190208044302.GA20493@dastard>
References: <20190206173114.GB12227@ziepe.ca>
 <20190206175233.GN21860@bombadil.infradead.org>
 <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
 <20190206210356.GZ6173@dastard>
 <20190206220828.GJ12227@ziepe.ca>
 <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
 <CAPcyv4hqya1iKCfHJRXQJRD4qXZa3VjkoKGw6tEvtWNkKVbP+A@mail.gmail.com>
 <bfe0fdd5400d41d223d8d30142f56a9c8efc033d.camel@redhat.com>
 <01000168c8e2de6b-9ab820ed-38ad-469c-b210-60fcff8ea81c-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01000168c8e2de6b-9ab820ed-38ad-469c-b210-60fcff8ea81c-000000@email.amazonses.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 07, 2019 at 04:55:37PM +0000, Christopher Lameter wrote:
> One approach that may be a clean way to solve this:
> 3. Filesystems that allow bypass of the page cache (like XFS / DAX) will
>    provide the virtual mapping when the PIN is done and DO NO OPERATIONS
>    on the longterm pinned range until the long term pin is removed.

So, ummm, how do we do block allocation then, which is done on
demand during writes?

IOWs, this requires the application to set up the file in the
correct state for the filesystem to lock it down so somebody else
can write to it.  That means the file can't be sparse, it can't be
preallocated (i.e. can't contain unwritten extents), it must have zeroes
written to it's full size before being shared because otherwise it
exposes stale data to the remote client (secure sites are going to
love that!), they can't be extended, etc.

IOWs, once the file is prepped and leased out for RDMA, it becomes
an immutable for the purposes of local access.

Which, essentially we can already do. Prep the file, map it
read/write, mark it immutable, then pin it via the longterm gup
interface which can do the necessary checks.

Simple to implement, the reasons for errors trying to modify the
file are already documented and queriable, and it's hard for
applications to get wrong.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

