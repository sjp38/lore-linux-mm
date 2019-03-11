Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9054C10F06
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 20:15:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86FA62147C
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 20:15:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86FA62147C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F7798E0006; Mon, 11 Mar 2019 16:15:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1A7408E0002; Mon, 11 Mar 2019 16:15:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0979A8E0006; Mon, 11 Mar 2019 16:15:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id B9C8E8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 16:15:56 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id f10so57139pgp.13
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 13:15:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=rQ7/RQ1j30ytbZd6sdAxzHy+Daowbu5PhrgpR35M1Cw=;
        b=RJofurifr2mbx01UiSyg6uaC22GrFuVyiUbjg9gICLxbv1Mz+PkgqlSIAry4W4m3eO
         Gtbc83dufnxxRq6WMEyH4ZgiBQZbD+schKazThGq+y/D4/wlxLSU1YPH5t0vqWAbxcw/
         zYC+SInaVCy3cLXQ76EuWhup8gWMlVz0ZmI01ptdGsRjIYOEj8uEO9UVG6HsfOQ4J55B
         BdFUPs9T5WYVbwWqcCZoWSMLLWqRJaN7ICLnwbfF+pNuzWbGlf587Dzt5J60o/w+BRh2
         4kq6RH5K5hoLl4+n84NwaTNwTDiZsDbr4ty0TZqy9x9cbrqnmuEVYCJ70i+VJ+6iG1iD
         DfSA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 134.134.136.100 as permitted sender) smtp.mailfrom=kbusch@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVXFQI+tVZOD91EA9wTpnFzro4NFFf9xJXlKPGdfCl0N7I9MtA5
	IVhZT3Z0Tjh/q2RHmAo6I6/caKka9IaOYXH8GRHiZGkaD4EaOBiuhQ1v9Q4xqrMmswbzoeGFJJh
	Zfd/UH4L7Jd+rQ/NEs/cI+hm3UsXVtyAEGAJw8O/S9ZhOWcZiYl2IU9xUxIj0LV8=
X-Received: by 2002:a62:f204:: with SMTP id m4mr34306672pfh.58.1552335356419;
        Mon, 11 Mar 2019 13:15:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw7GFxJpVHw9ZJzd/GAorvk7Tj+NCPKkulM1/BUsR6kF5FH7AoCQLIqqi0bIhklcjNycmmD
X-Received: by 2002:a62:f204:: with SMTP id m4mr34306605pfh.58.1552335355186;
        Mon, 11 Mar 2019 13:15:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552335355; cv=none;
        d=google.com; s=arc-20160816;
        b=qENrtUlFKeqjzavxBEOcGp2o8aSCLzACdMykyqC3h0a3ySGNW1SwIeEhBVQ0NxzttI
         9rTkrIBke6+C60k/6MCupcIQcYOwqd46RehaZM1Wz0wXJfTs8+t5Qad4xp0ZhBYizQg4
         SuY/OpaeKiWKBye00Hm07ULuzbh6aWJwAl1zV9o5sZvCC9kP16XGQVQd0nIgh6v8aRaf
         DfSretX3sQwP2dkC+hha2Q/NsCajzaWXrkyw0DXfHTaF18SxcPEx8npN63iEiDUPmBGs
         fl5wq3EOLNC08CA0w/X6iCIQw+xPytuT7sywI49kbvgz4Yo0KY/eBimDyujeN6iXT7Da
         9OdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=rQ7/RQ1j30ytbZd6sdAxzHy+Daowbu5PhrgpR35M1Cw=;
        b=FNiwjIUbqud4oq4hPHvcoUt70CNjhoBMPzqWgZhwu8/Nk9Ovko8Fa5DiSKH4wcj/N+
         PRszEiUzlhLSFfPEAys3quPtas/uJ0ptijdum2U51eCfqncBYcWXSh05PuvpSCNR0aOT
         eYaMW4TJRb4rkBdptpDY7JV9rtoZ7PokHAbTPAcbIgbEOb4wISIgw7JPZhV/h0KO/UGw
         p5UEfychAIlA4VlZyppIBCAJ6QlYw70nsVZgNI/cIuiftPef5E2rwX9xxePE1djvVCwu
         Pp88AxInDS6UIvNI8nM12Cup+4N7g41KmPW3bn/2MfZEQ2smXCqr9IVEBSZiiI+Fveow
         m9AQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 134.134.136.100 as permitted sender) smtp.mailfrom=kbusch@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id f3si5822072pfn.122.2019.03.11.13.15.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 13:15:55 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 134.134.136.100 as permitted sender) smtp.mailfrom=kbusch@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Mar 2019 13:15:54 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,468,1544515200"; 
   d="scan'208";a="327630203"
Received: from unknown (HELO localhost.localdomain) ([10.232.112.69])
  by fmsmga005.fm.intel.com with ESMTP; 11 Mar 2019 13:15:53 -0700
Date: Mon, 11 Mar 2019 14:16:33 -0600
From: Keith Busch <kbusch@kernel.org>
To: Jonathan Cameron <jonathan.cameron@huawei.com>
Cc: "Busch, Keith" <keith.busch@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-api@vger.kernel.org" <linux-api@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Rafael Wysocki <rafael@kernel.org>,
	"Hansen, Dave" <dave.hansen@intel.com>,
	"Williams, Dan J" <dan.j.williams@intel.com>
Subject: Re: [PATCHv7 10/10] doc/mm: New documentation for memory performance
Message-ID: <20190311201632.GG10411@localhost.localdomain>
References: <20190227225038.20438-1-keith.busch@intel.com>
 <20190227225038.20438-11-keith.busch@intel.com>
 <20190311113843.00006b47@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190311113843.00006b47@huawei.com>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 04:38:43AM -0700, Jonathan Cameron wrote:
> On Wed, 27 Feb 2019 15:50:38 -0700
> Keith Busch <keith.busch@intel.com> wrote:
> 
> > Platforms may provide system memory where some physical address ranges
> > perform differently than others, or is side cached by the system.
> The magic 'side cached' term still here in the patch description, ideally
> wants cleaning up.
> 
> > 
> > Add documentation describing a high level overview of such systems and the
> > perforamnce and caching attributes the kernel provides for applications
> performance
> 
> > wishing to query this information.
> > 
> > Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>
> > Signed-off-by: Keith Busch <keith.busch@intel.com>
> 
> A few comments inline. Mostly the weird corner cases that I miss understood
> in one of the earlier versions of the code.
> 
> Whilst I think perhaps that one section could be tweaked a tiny bit I'm basically
> happy with this if you don't want to.
> 
> Reviewed-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>
> 
> > ---
> >  Documentation/admin-guide/mm/numaperf.rst | 164 ++++++++++++++++++++++++++++++
> >  1 file changed, 164 insertions(+)
> >  create mode 100644 Documentation/admin-guide/mm/numaperf.rst
> > 
> > diff --git a/Documentation/admin-guide/mm/numaperf.rst b/Documentation/admin-guide/mm/numaperf.rst
> > new file mode 100644
> > index 000000000000..d32756b9be48
> > --- /dev/null
> > +++ b/Documentation/admin-guide/mm/numaperf.rst
> > @@ -0,0 +1,164 @@
> > +.. _numaperf:
> > +
> > +=============
> > +NUMA Locality
> > +=============
> > +
> > +Some platforms may have multiple types of memory attached to a compute
> > +node. These disparate memory ranges may share some characteristics, such
> > +as CPU cache coherence, but may have different performance. For example,
> > +different media types and buses affect bandwidth and latency.
> > +
> > +A system supports such heterogeneous memory by grouping each memory type
> > +under different domains, or "nodes", based on locality and performance
> > +characteristics.  Some memory may share the same node as a CPU, and others
> > +are provided as memory only nodes. While memory only nodes do not provide
> > +CPUs, they may still be local to one or more compute nodes relative to
> > +other nodes. The following diagram shows one such example of two compute
> > +nodes with local memory and a memory only node for each of compute node:
> > +
> > + +------------------+     +------------------+
> > + | Compute Node 0   +-----+ Compute Node 1   |
> > + | Local Node0 Mem  |     | Local Node1 Mem  |
> > + +--------+---------+     +--------+---------+
> > +          |                        |
> > + +--------+---------+     +--------+---------+
> > + | Slower Node2 Mem |     | Slower Node3 Mem |
> > + +------------------+     +--------+---------+
> > +
> > +A "memory initiator" is a node containing one or more devices such as
> > +CPUs or separate memory I/O devices that can initiate memory requests.
> > +A "memory target" is a node containing one or more physical address
> > +ranges accessible from one or more memory initiators.
> > +
> > +When multiple memory initiators exist, they may not all have the same
> > +performance when accessing a given memory target. Each initiator-target
> > +pair may be organized into different ranked access classes to represent
> > +this relationship. 
> 
> This concept is a bit vague at the moment. Largely because only access0
> is actually defined.  We should definitely keep a close eye on any others
> that are defined in future to make sure this text is still valid.
> 
> I can certainly see it being used for different ideas of 'best' rather
> than simply best and second best etc.

I tried to make the interface flexible to future extension, but I'm
still not sure how potential users would want to see something like
all pair-wise attributes, so I had some trouble trying to capture that
in words.
 
> > The highest performing initiator to a given target
> > +is considered to be one of that target's local initiators, and given
> > +the highest access class, 0. Any given target may have one or more
> > +local initiators, and any given initiator may have multiple local
> > +memory targets.
> > +
> > +To aid applications matching memory targets with their initiators, the
> > +kernel provides symlinks to each other. The following example lists the
> > +relationship for the access class "0" memory initiators and targets, which is
> > +the of nodes with the highest performing access relationship::
> > +
> > +	# symlinks -v /sys/devices/system/node/nodeX/access0/targets/
> > +	relative: /sys/devices/system/node/nodeX/access0/targets/nodeY -> ../../nodeY
> 
> So this one perhaps needs a bit more description - I would put it after initiators
> which precisely fits the description you have here now.
> 
> "targets contains those nodes for which this initiator is the best possible initiator."
> 
> which is subtly different form
> 
> "targets contains those nodes to which this node has the highest
> performing access characteristics."
> 
> For example in my test case:
> * 4 nodes with local memory and cpu, 1 node remote and equal distant from all of the
>   initiators,
> 
> targets for the compute nodes contains both themselves and the remote node, to which
> the characteristics are of course worse. As you point out before, we need to look
> in 
> node0/access0/targets/node0/access0/initiators 
> node0/access0/targets/node4/access0/initiators 
> to get the relevant characteristics and work out that node0 is 'nearer' itself
> (obviously this is a bit of a silly case, but we could have no memory node0 and
> be talking about node4 and node5.
> 
> I am happy with the actual interface, this is just a question about whether we can tweak
> this text to be slightly clearer.

Sure, I mention this in patch 4's commit message. Probably worth
repeating here:

    A memory initiator may have multiple memory targets in the same access
    class. The target memory's initiators in a given class indicate the
    nodes access characteristics share the same performance relative to other
    linked initiator nodes. Each target within an initiator's access class,
    though, do not necessarily perform the same as each other.

