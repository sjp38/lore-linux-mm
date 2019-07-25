Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49E31C76194
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 20:00:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 101432190F
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 20:00:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 101432190F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9BF066B0003; Thu, 25 Jul 2019 16:00:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 970D26B0005; Thu, 25 Jul 2019 16:00:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 885936B0006; Thu, 25 Jul 2019 16:00:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 547506B0003
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 16:00:09 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id z14so24350972pgr.22
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 13:00:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=5FiYrm9No595AgyPC1IYR9NTuGQ4xA95R4m5fC/yjic=;
        b=NWS7wdiX9S0LZG2LonJx2AWyiBv+IAkszbfVmefVoA5XNIn/wEWPEaeJYI0AJbP51K
         IYDQgBet+zuWHI4uW/giF4jKqgmcG5NVFNrH1rWYaTPf3ruVysVbp24hbT9QDUX7qbIO
         GGaXbnwt21iI+J2ptf9sDnDCa2N+0xDrGHSmZtrLMEp8LDuytwmtnGSaFPtbX+NxRQmG
         d7vagB7L1XkVXPN7Jw7KgOOvQ8K7RELrX3vnO9NX9QOiVWLETukWeXBlpMC8/9J9mgVr
         Ev8P38pX0FMS3dy5ga6oiivwXIatGYnqXk61fzNEVhAzRI8gjp0RdpW4RNJKQ2CLddGw
         yqZQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXfdDvr6hpJCiYXMMBkZcC/MSrQYzpoG8l24QtgL+NFUbs6t2Wo
	DUkjU2tztG3XHWIeiz94qDwJAyAnMINP4yCFUVCD4NjuhonvOiEH/pwkUw9eBDeE2gulgh9gIjv
	7p/XGL6Rov+Lv/Patb6CUWPDg7/IeXb9ygMBc4qx4NUX7csaqEHKC76t8fCS2zfHzqQ==
X-Received: by 2002:a63:d210:: with SMTP id a16mr85780098pgg.77.1564084808826;
        Thu, 25 Jul 2019 13:00:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyi6aY5uwQuQAmVh/JB55jG6FXrAWCWv/rmw4pz1Jg6qn+VW6FvUvSUs4qX4TjXga7kgjkJ
X-Received: by 2002:a63:d210:: with SMTP id a16mr85780030pgg.77.1564084807862;
        Thu, 25 Jul 2019 13:00:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564084807; cv=none;
        d=google.com; s=arc-20160816;
        b=bVnmpEA/fwcnW3KQT4x9m9hM692eY50I4u8U1HO/3jCKYWwJg2MFZK1i5x+1ibZTzz
         DFXNy9LFHKqbFLF4CNsEvER1YQL2sLDCtFxez2O2Rdv25O6BSebsHLiS2eZtkF2pRpnU
         mekRRejCyAqAwFYkqwuo3m+Qt7/mBj76I6bIruBKBNv/vEOYtM3HU0MgO+RbpZvr9Wcd
         qvh7IuDUE965yiixlyu5vM9HYjXG0+ROU2JrHpDfcizzlFcvS00yh8Zy6WC+6UZnHpSd
         80eS2hcEiT5tp5jjtffyQ8+Og/TYSqQXESYhoUlKrX2/Bkb2o8ZpD/iqFSefLIVdk89Z
         ZiWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id;
        bh=5FiYrm9No595AgyPC1IYR9NTuGQ4xA95R4m5fC/yjic=;
        b=bYlxFASmi9rtzeJVf6Zz341k0DaATXjn0RzpFwKqlFw0KBPjbx/ePljXgKsGB9XS7/
         NwUDXK2CfjMaPQD39OP5fGsufEQE+b7SLMjN5NHYL/9BxD66zC4howbbdznGAIVW3iKc
         nJwapqS2ih4sNmyTzS6iWvy/f5h4ck+a7rRgxhpPuzOYLRgxZdaXRRjHHHYMHegaKHnP
         H7OvzJoJdZ3zfwvegRG71wwEc429mqHhJDhNjdxzEsoKLkkj2VadEEtFRXpMf0JomK4H
         3tWEoEO53VgQffkhgEJeAOG1hbVOXHxDHzHzleb0BkX8eWMQL/5gpBRj5bhjWiVXI+Bn
         mDbw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id r33si15962195pjb.76.2019.07.25.13.00.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 13:00:07 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Jul 2019 13:00:07 -0700
X-IronPort-AV: E=Sophos;i="5.64,307,1559545200"; 
   d="scan'208";a="254074357"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga001-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Jul 2019 13:00:07 -0700
Message-ID: <6bee80b95885e74a5e46e3bd3e708d092b4a666f.camel@linux.intel.com>
Subject: Re: [PATCH v2 QEMU] virtio-balloon: Provide a interface for "bubble
 hinting"
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: Nitesh Narayan Lal <nitesh@redhat.com>, "Michael S. Tsirkin"
	 <mst@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, kvm@vger.kernel.org, 
	david@redhat.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, 
	linux-mm@kvack.org, akpm@linux-foundation.org, yang.zhang.wz@gmail.com, 
	pagupta@redhat.com, riel@surriel.com, konrad.wilk@oracle.com, 
	lcapitulino@redhat.com, wei.w.wang@intel.com, aarcange@redhat.com, 
	pbonzini@redhat.com, dan.j.williams@intel.com
Date: Thu, 25 Jul 2019 13:00:07 -0700
In-Reply-To: <cc98f7c9-bcf8-79cb-54b7-de7c996f76e1@redhat.com>
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
	 <20190724171050.7888.62199.stgit@localhost.localdomain>
	 <20190724173403-mutt-send-email-mst@kernel.org>
	 <ada4e7d932ebd436d00c46e8de699212e72fd989.camel@linux.intel.com>
	 <fed474fe-93f4-a9f6-2e01-75e8903edd81@redhat.com>
	 <bc162a5eaa58ac074c8ad20cb23d579aa04d0f43.camel@linux.intel.com>
	 <20190725111303-mutt-send-email-mst@kernel.org>
	 <96b1ac42dccbfbb5dd17210e6767ca2544558390.camel@linux.intel.com>
	 <cc98f7c9-bcf8-79cb-54b7-de7c996f76e1@redhat.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-07-25 at 14:25 -0400, Nitesh Narayan Lal wrote:
> On 7/25/19 12:16 PM, Alexander Duyck wrote:
> > On Thu, 2019-07-25 at 11:16 -0400, Michael S. Tsirkin wrote:
> > > On Thu, Jul 25, 2019 at 08:05:30AM -0700, Alexander Duyck wrote:
> > > > On Thu, 2019-07-25 at 07:35 -0400, Nitesh Narayan Lal wrote:
> > > > > On 7/24/19 6:03 PM, Alexander Duyck wrote:
> > > > > > On Wed, 2019-07-24 at 17:38 -0400, Michael S. Tsirkin wrote:
> > > > > > > On Wed, Jul 24, 2019 at 10:12:10AM -0700, Alexander Duyck wrote:
> > > > > > > > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > > > > > > 
> > > > > > > 

<snip>


> > Ideally we should be able
> > to provide the hints and have them feed whatever is supposed to be using
> > them. So for example I could probably look at also clearing the bitmaps
> > when migration is in process.
> > 
> > Also, I am wonder if the free page hints would be redundant with the form
> > of page hinting/reporting that I have since we should be migrating a much
> > smaller footprint anyway if the pages have been madvised away before we
> > even start the migration.
> > 
> > > FWIW Nitesh's RFC does not have this limitation.
> > Yes, but there are also limitations to his approach. For example the fact
> > that the bitmap it maintains is back to being a hint rather then being
> > very exact.
> 
> True.
> 
> 
> >  As a result you could end up walking the bitmap for a while
> > clearing bits without ever finding a free page.
> 
> Are referring to the overhead which will be introduced due to bitmap scanning on
> very large guests?

Yes. One concern I have had is that for large memory footprints the RFC
would end up having a large number of false positives on an highly active
system. I am worried it will result in a feedback loop where having more
false hits slows down your processing speed, and the slower your
processing speed the more likely you are to encounter more false hits.

