Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A98F8C10F00
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 13:38:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 554062075C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 13:38:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 554062075C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE6948E0004; Tue, 12 Mar 2019 09:38:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E948A8E0002; Tue, 12 Mar 2019 09:38:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DABB28E0004; Tue, 12 Mar 2019 09:38:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id AF1558E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 09:38:24 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id 5so899539vkg.20
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 06:38:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=m1mjK4sKFZ/17pgsPcb0jBgwVJQULZRieA1aW4xGA5U=;
        b=GBUsWh3VDagPd8IE9r0OUs5UIXLWfBN/u6trlM5MMUUmPchiU1Wnbmwsa4tE2RPXkY
         nEWENtIdQZBFbWzotqxUq1bFxQ11RcTtGVuiCQ05PY9f2VKcUwVsoXrG5s8CBnC/b3Zl
         V35k64t6KMN9s1HJXnYDeCVz2JvtJRjwIoyvvOaioceFr9ZzHrxQBXL55TOBZGcVVcGm
         bKXrMmgEaRY63/0Qm5dUKzU4huVb3T55dt6UXAVAl+4It5F8OiqZvGz/1PEWk+Frbcjp
         I/lge7hvj7wiJFi3dzyaEuCoJ2u7L1pQdL94sboQmobEI0nbOXxZD1gDZOanixBUcyVs
         coaw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: APjAAAUDFIm7MrILEcOzkyaWTsXbfM5+55xJuS2UsNPDtKxHxsAzKtA3
	R2udkiaMNW47F/wo4nDiAvYeq2xqJCHbpEKByc4MF5uffqtA1IYh5sSe26C3xQBf2nnXm22CxcL
	SdbTfP/Pq+NAugPc6dqvSqddB6D+/bz/9UneyZKXbk/k/WUsAtN3oWyggUPGXScKHYg==
X-Received: by 2002:a67:ed9a:: with SMTP id d26mr1358050vsp.194.1552397904241;
        Tue, 12 Mar 2019 06:38:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyE7BDV0wmNL5YAsCWZcOKfZzbPf6kyO5FpC81+CiwxpioLlyus3r+4vYNxVExIokQmvZ+C
X-Received: by 2002:a67:ed9a:: with SMTP id d26mr1357991vsp.194.1552397903014;
        Tue, 12 Mar 2019 06:38:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552397903; cv=none;
        d=google.com; s=arc-20160816;
        b=aK4dFFrwl6ZF/Y9rqHN7GlHbTTRP5E/IBq1lll82blEkbno3VIA3b4eQD4Yh8zBGQ7
         RsFO0pQhLbS/vf9ZVodUR7v2Jf/G/yrKVCfMB2mdxRE6l9hlh13vP23iOSfILbDbAY7E
         oIzU5UyJHwpVsyFal+1Lnny3RpBlSLNRD1jAHRbDiJhXsVTF6YQ0xIZ/Il6V9VyFINRT
         yltjYRhcByi+cUSB1f4Nxh74T+IqZ6NKN6TugNB75ubQyJVKxCRxbrDUpo6/fgGv1qZs
         lvUkhmM5jV9nuPdYGhrkbOP0qR8lHo3TEafldRkITL39iFsCUrtYGOe2BMhba3Q0jLwB
         je4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=m1mjK4sKFZ/17pgsPcb0jBgwVJQULZRieA1aW4xGA5U=;
        b=pSG30alCeUEMMzSeeuC7PT2giybEGLkkvJVYmnPp5X3fot3oPTlS8a9k44Q+O8Rx3K
         KgPrL5A1DAKlEZKjewX8UqCflgmeQ6Hot+Bax9BVBkviwrPm14mLJVK5VFUvwkbabnrY
         DDpGOC0pt2ExfRpw+JE2iP1UtUObeeLInlSq/LsMA7GEdXBHGSn17C6Zl8XKmq/kOqs5
         +8uLayjGnJvQXFDjH/bVUpm09Fyk2GspUvTEwawW19OgqYokSCtFtpw2KDEruogv7ZC5
         TAmGhbE322Bk5Cw218+fV3QLmUgRimsUUNEytkzAOxDMEfW+KuCUKxHlk+DQ8rJejuS/
         OanA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id n18si1683748vsm.190.2019.03.12.06.38.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 06:38:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS403-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 77D1FE6603A2B2CFAEB4;
	Tue, 12 Mar 2019 21:38:17 +0800 (CST)
Received: from localhost (10.202.226.61) by DGGEMS403-HUB.china.huawei.com
 (10.3.19.203) with Microsoft SMTP Server id 14.3.408.0; Tue, 12 Mar 2019
 21:38:11 +0800
Date: Tue, 12 Mar 2019 13:37:56 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
To: Keith Busch <kbusch@kernel.org>
CC: "Busch, Keith" <keith.busch@intel.com>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "linux-acpi@vger.kernel.org"
	<linux-acpi@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-api@vger.kernel.org" <linux-api@vger.kernel.org>, Greg Kroah-Hartman
	<gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, "Hansen,
 Dave" <dave.hansen@intel.com>, "Williams, Dan J" <dan.j.williams@intel.com>
Subject: Re: [PATCHv7 10/10] doc/mm: New documentation for memory
 performance
Message-ID: <20190312133756.000066c7@huawei.com>
In-Reply-To: <20190311201632.GG10411@localhost.localdomain>
References: <20190227225038.20438-1-keith.busch@intel.com>
	<20190227225038.20438-11-keith.busch@intel.com>
	<20190311113843.00006b47@huawei.com>
	<20190311201632.GG10411@localhost.localdomain>
Organization: Huawei
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; i686-w64-mingw32)
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.202.226.61]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Mar 2019 14:16:33 -0600
Keith Busch <kbusch@kernel.org> wrote:

> On Mon, Mar 11, 2019 at 04:38:43AM -0700, Jonathan Cameron wrote:
> > On Wed, 27 Feb 2019 15:50:38 -0700
> > Keith Busch <keith.busch@intel.com> wrote:
> >   
> > > Platforms may provide system memory where some physical address ranges
> > > perform differently than others, or is side cached by the system.  
> > The magic 'side cached' term still here in the patch description, ideally
> > wants cleaning up.
> >   
> > > 
> > > Add documentation describing a high level overview of such systems and the
> > > perforamnce and caching attributes the kernel provides for applications  
> > performance
> >   
> > > wishing to query this information.
> > > 
> > > Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>
> > > Signed-off-by: Keith Busch <keith.busch@intel.com>  
> > 
> > A few comments inline. Mostly the weird corner cases that I miss understood
> > in one of the earlier versions of the code.
> > 
> > Whilst I think perhaps that one section could be tweaked a tiny bit I'm basically
> > happy with this if you don't want to.
> > 
> > Reviewed-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>
> >   
> > > ---
> > >  Documentation/admin-guide/mm/numaperf.rst | 164 ++++++++++++++++++++++++++++++
> > >  1 file changed, 164 insertions(+)
> > >  create mode 100644 Documentation/admin-guide/mm/numaperf.rst
> > > 
> > > diff --git a/Documentation/admin-guide/mm/numaperf.rst b/Documentation/admin-guide/mm/numaperf.rst
> > > new file mode 100644
> > > index 000000000000..d32756b9be48
> > > --- /dev/null
> > > +++ b/Documentation/admin-guide/mm/numaperf.rst
> > > @@ -0,0 +1,164 @@
> > > +.. _numaperf:
> > > +
> > > +=============
> > > +NUMA Locality
> > > +=============
> > > +
> > > +Some platforms may have multiple types of memory attached to a compute
> > > +node. These disparate memory ranges may share some characteristics, such
> > > +as CPU cache coherence, but may have different performance. For example,
> > > +different media types and buses affect bandwidth and latency.
> > > +
> > > +A system supports such heterogeneous memory by grouping each memory type
> > > +under different domains, or "nodes", based on locality and performance
> > > +characteristics.  Some memory may share the same node as a CPU, and others
> > > +are provided as memory only nodes. While memory only nodes do not provide
> > > +CPUs, they may still be local to one or more compute nodes relative to
> > > +other nodes. The following diagram shows one such example of two compute
> > > +nodes with local memory and a memory only node for each of compute node:
> > > +
> > > + +------------------+     +------------------+
> > > + | Compute Node 0   +-----+ Compute Node 1   |
> > > + | Local Node0 Mem  |     | Local Node1 Mem  |
> > > + +--------+---------+     +--------+---------+
> > > +          |                        |
> > > + +--------+---------+     +--------+---------+
> > > + | Slower Node2 Mem |     | Slower Node3 Mem |
> > > + +------------------+     +--------+---------+
> > > +
> > > +A "memory initiator" is a node containing one or more devices such as
> > > +CPUs or separate memory I/O devices that can initiate memory requests.
> > > +A "memory target" is a node containing one or more physical address
> > > +ranges accessible from one or more memory initiators.
> > > +
> > > +When multiple memory initiators exist, they may not all have the same
> > > +performance when accessing a given memory target. Each initiator-target
> > > +pair may be organized into different ranked access classes to represent
> > > +this relationship.   
> > 
> > This concept is a bit vague at the moment. Largely because only access0
> > is actually defined.  We should definitely keep a close eye on any others
> > that are defined in future to make sure this text is still valid.
> > 
> > I can certainly see it being used for different ideas of 'best' rather
> > than simply best and second best etc.  
> 
> I tried to make the interface flexible to future extension, but I'm
> still not sure how potential users would want to see something like
> all pair-wise attributes, so I had some trouble trying to capture that
> in words.

Agreed, it is definitely non obvious.  We might end up with something
totally different like Jerome is proposing anyway.  Let's address
this when it happens!

>  
> > > The highest performing initiator to a given target
> > > +is considered to be one of that target's local initiators, and given
> > > +the highest access class, 0. Any given target may have one or more
> > > +local initiators, and any given initiator may have multiple local
> > > +memory targets.
> > > +
> > > +To aid applications matching memory targets with their initiators, the
> > > +kernel provides symlinks to each other. The following example lists the
> > > +relationship for the access class "0" memory initiators and targets, which is
> > > +the of nodes with the highest performing access relationship::
> > > +
> > > +	# symlinks -v /sys/devices/system/node/nodeX/access0/targets/
> > > +	relative: /sys/devices/system/node/nodeX/access0/targets/nodeY -> ../../nodeY  
> > 
> > So this one perhaps needs a bit more description - I would put it after initiators
> > which precisely fits the description you have here now.
> > 
> > "targets contains those nodes for which this initiator is the best possible initiator."
> > 
> > which is subtly different form
> > 
> > "targets contains those nodes to which this node has the highest
> > performing access characteristics."
> > 
> > For example in my test case:
> > * 4 nodes with local memory and cpu, 1 node remote and equal distant from all of the
> >   initiators,
> > 
> > targets for the compute nodes contains both themselves and the remote node, to which
> > the characteristics are of course worse. As you point out before, we need to look
> > in 
> > node0/access0/targets/node0/access0/initiators 
> > node0/access0/targets/node4/access0/initiators 
> > to get the relevant characteristics and work out that node0 is 'nearer' itself
> > (obviously this is a bit of a silly case, but we could have no memory node0 and
> > be talking about node4 and node5.
> > 
> > I am happy with the actual interface, this is just a question about whether we can tweak
> > this text to be slightly clearer.  
> 
> Sure, I mention this in patch 4's commit message. Probably worth
> repeating here:
> 
>     A memory initiator may have multiple memory targets in the same access
>     class. The target memory's initiators in a given class indicate the
>     nodes access characteristics share the same performance relative to other
>     linked initiator nodes. Each target within an initiator's access class,
>     though, do not necessarily perform the same as each other.
That sounds good to me.



