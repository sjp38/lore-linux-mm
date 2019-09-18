Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6CF3CC4CEC4
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 18:05:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B74E21897
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 18:05:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B74E21897
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B336D6B02F6; Wed, 18 Sep 2019 14:05:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE46F6B02F8; Wed, 18 Sep 2019 14:05:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D3766B02F9; Wed, 18 Sep 2019 14:05:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0039.hostedemail.com [216.40.44.39])
	by kanga.kvack.org (Postfix) with ESMTP id 7BC9E6B02F6
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 14:05:13 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 2B6AA1F86A
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 18:05:13 +0000 (UTC)
X-FDA: 75948818106.21.slave92_84cb43b45055d
X-HE-Tag: slave92_84cb43b45055d
X-Filterd-Recvd-Size: 3104
Received: from mga07.intel.com (mga07.intel.com [134.134.136.100])
	by imf45.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 18:05:12 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Sep 2019 11:05:10 -0700
X-IronPort-AV: E=Sophos;i="5.64,521,1559545200"; 
   d="scan'208";a="338407459"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga004-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Sep 2019 11:05:10 -0700
Message-ID: <38429bdb416bdb33f3c7f740f903380af3129a36.camel@linux.intel.com>
Subject: Re: [PATCH v10 5/6] virtio-balloon: Pull page poisoning config out
 of free page hinting
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: "Michael S. Tsirkin" <mst@redhat.com>, Alexander Duyck
	 <alexander.duyck@gmail.com>
Cc: virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, david@redhat.com, 
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, willy@infradead.org, 
 mhocko@kernel.org, linux-mm@kvack.org, vbabka@suse.cz,
 akpm@linux-foundation.org,  mgorman@techsingularity.net,
 linux-arm-kernel@lists.infradead.org,  osalvador@suse.de,
 yang.zhang.wz@gmail.com, pagupta@redhat.com,  konrad.wilk@oracle.com,
 nitesh@redhat.com, riel@surriel.com,  lcapitulino@redhat.com,
 wei.w.wang@intel.com, aarcange@redhat.com,  pbonzini@redhat.com,
 dan.j.williams@intel.com
Date: Wed, 18 Sep 2019 11:05:10 -0700
In-Reply-To: <20190918135833-mutt-send-email-mst@kernel.org>
References: <20190918175109.23474.67039.stgit@localhost.localdomain>
	 <20190918175305.23474.34783.stgit@localhost.localdomain>
	 <20190918135833-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-09-18 at 13:58 -0400, Michael S. Tsirkin wrote:
> On Wed, Sep 18, 2019 at 10:53:05AM -0700, Alexander Duyck wrote:
> > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > 
> > Currently the page poisoning setting wasn't being enabled unless free page
> > hinting was enabled. However we will need the page poisoning tracking logic
> > as well for unused page reporting. As such pull it out and make it a
> > separate bit of config in the probe function.
> > 
> > In addition we can actually wrap the code in a check for NO_SANITY. If we
> > don't care what is actually in the page we can just default to 0 and leave
> > it there.
> > 
> > Reviewed-by: David Hildenbrand <david@redhat.com>
> > Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> 
> I think this one can go in directly. Do you want me to merge it now?

That sounds good to me.

Do you know if you can also pull in QEMU 1/3 into QEMU as well since the
feature wasn't pulled into QEMU originally?
https://lore.kernel.org/lkml/20190918175342.23606.12400.stgit@localhost.localdomain/

Thanks.

- Alex



