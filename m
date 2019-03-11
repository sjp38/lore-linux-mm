Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39A51C10F06
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 19:52:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 02F4920643
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 19:52:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 02F4920643
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 675BC8E0003; Mon, 11 Mar 2019 15:52:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 625BF8E0002; Mon, 11 Mar 2019 15:52:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 53BCD8E0003; Mon, 11 Mar 2019 15:52:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 122868E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 15:52:08 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id w16so252857pfn.3
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 12:52:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=j3MsXv0zF33ae8whTZJIJRm3rgd+bPbkqW1T66RN8oU=;
        b=GtK1OBRzkB6S69aBfcWJZqv0pyAmzhCkmAKyqB4cced40OZ2xcTxl0OVRxiJu9Q1Hy
         WfU0peiJKzCc8qBvSr+6uOg98DDLKS0dwogYlVIElUOimcH1qeZCgqTSSrOtGmjD4K0A
         tvPWNxVI1QrVqxPKR8Sly8h1jZ+gGACUf9X5OvUq4cYLo2t4ZJWhAT/rInkuXHDm6HKb
         Q9TZFjuo+3kBqqwhRSgM4D9XBsYQ4yMsztfIHf15/PeP0rIetZ1ZLpD0OcZrs5pb3evw
         q/0A3672EnJKjorsgRfEkzwWNKRT1Hmh12xbzr+9d3WENOS/GQ0A7Bv8xuNvftzQ3MqD
         oYbw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 134.134.136.24 as permitted sender) smtp.mailfrom=kbusch@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAV8ihg7u1T0ugG67Zo4Fr34/2U1Y5gmNjqFEF8E9VvfQFZhIxEh
	VPsewm4pml9zj+8fUC0TbtqgBQqJtro7nj9U9ITQys6UfgiXJwuDpLZn9ZI7CWXPcgVvUG9H6pz
	MmKYx2PiMB6PoewHsu4zQjJtqj6wikJP5tyzcXUmIBBeFMz5sUW2AaTux4CAxxDA=
X-Received: by 2002:a17:902:112c:: with SMTP id d41mr35633734pla.177.1552333927762;
        Mon, 11 Mar 2019 12:52:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxr1Iy6WQI/86BU9+X+OxEFofZqKDWNGsQAcdQ/OXweTW8+ZAdFFENqFip9/Vc8OtLjXwko
X-Received: by 2002:a17:902:112c:: with SMTP id d41mr35633632pla.177.1552333926602;
        Mon, 11 Mar 2019 12:52:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552333926; cv=none;
        d=google.com; s=arc-20160816;
        b=RIFrpbiXfw1hiyHf1xKm75OFBH4Gr8CpBonFLW1+CBX1WTVOew2W0HExVfXRC4cbCJ
         85EJt8qP01xGf5pQepvpp/tONqja4qnkGxmQNK4A78tpgpeUbIrLrohThUSK5qubb82l
         FKoiApsuECRNfXzS7RmVPM5iZeo4JJ40GCXrQ77qPRM1zvmXtd5W/JnJa23DxsrtA0vK
         uPjnmvVBJNWH4alHIxkhPE36eQCuCgx4KdvAKsb0MFQIr5qwbFDk353jmitcYpnewOFw
         l9LwxcglO/hEBoon3xfm2R8qKaADmU0efcBnhsGsJIyB1FVXetvR+R6Gb5Bld/+Cd5Sb
         wsIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=j3MsXv0zF33ae8whTZJIJRm3rgd+bPbkqW1T66RN8oU=;
        b=VI3DxRBMxccrAfBoBGpRoQd8wPbCBRz/xA4IMsldkXATrMSc11gsC8rop4EkJV66Lj
         IWxhtKtjFi6qEqn6sAtFEtmCMep8VVUAeglTJOB9KJQM+kAcXHP8hHNGFcb1Nfe6woia
         O1F5LS05Y8td1omtiUG6MoNAAg3xkyqtmpL3Lktz3GOFKZKCJzf6dg19aIqo8opbCvk7
         wMaA4M1z6qk1e2Sw4Ph+LABMjdDXfQwv1D8GelZgJANN0z+v0AzjH+Bu8/9zFpKi1Z5w
         Em1c5U/++shpgndVbfLIt0ANxNPhKgelArV44PWbkAZTszCiV3krgofkDje8bu0JwUyR
         hKHw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 134.134.136.24 as permitted sender) smtp.mailfrom=kbusch@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id x12si5469956pgp.286.2019.03.11.12.52.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 12:52:06 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 134.134.136.24 as permitted sender) smtp.mailfrom=kbusch@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Mar 2019 12:52:06 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,468,1544515200"; 
   d="scan'208";a="281718711"
Received: from unknown (HELO localhost.localdomain) ([10.232.112.69])
  by orsmga004.jf.intel.com with ESMTP; 11 Mar 2019 12:52:05 -0700
Date: Mon, 11 Mar 2019 13:52:44 -0600
From: Keith Busch <kbusch@kernel.org>
To: Jonathan Cameron <jonathan.cameron@huawei.com>
Cc: Keith Busch <keith.busch@intel.com>, linux-kernel@vger.kernel.org,
	linux-acpi@vger.kernel.org, linux-mm@kvack.org,
	linux-api@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Rafael Wysocki <rafael@kernel.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCHv7 07/10] acpi/hmat: Register processor domain to its
 memory
Message-ID: <20190311195244.GF10411@localhost.localdomain>
References: <20190227225038.20438-1-keith.busch@intel.com>
 <20190227225038.20438-8-keith.busch@intel.com>
 <20190311112041.000015ba@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190311112041.000015ba@huawei.com>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 11:20:41AM +0000, Jonathan Cameron wrote:
> On Wed, 27 Feb 2019 15:50:35 -0700
> Keith Busch <keith.busch@intel.com> wrote:
> > +static __init void hmat_register_target_initiators(struct memory_target *target)
> > +{
> > +	static DECLARE_BITMAP(p_nodes, MAX_NUMNODES);
> > +	struct memory_initiator *initiator;
> > +	unsigned int mem_nid, cpu_nid;
> > +	struct memory_locality *loc = NULL;
> > +	u32 best = 0;
> > +	int i;
> > +
> (upshot of the below is I removed this test :)
> > +	if (target->processor_pxm == PXM_INVAL)
> > +		return;
> 
> This doesn't look right.  We check first if it is invalid  and return....

Yeah, Brice mentioned the same bug. I must have been mistakenly
reintroduced that when I rebased to linux-next. I also have a test case
for this and recall it was working at one point. I've got it fixed up
now for the next revision.

