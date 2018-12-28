Return-Path: <SRS0=dGUi=PF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C870CC43387
	for <linux-mm@archiver.kernel.org>; Fri, 28 Dec 2018 03:06:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D54B2146F
	for <linux-mm@archiver.kernel.org>; Fri, 28 Dec 2018 03:06:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D54B2146F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 17DC38E002D; Thu, 27 Dec 2018 22:06:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 12E988E0001; Thu, 27 Dec 2018 22:06:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0443E8E002D; Thu, 27 Dec 2018 22:06:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id BB31C8E0001
	for <linux-mm@kvack.org>; Thu, 27 Dec 2018 22:06:49 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id o17so18994554pgi.14
        for <linux-mm@kvack.org>; Thu, 27 Dec 2018 19:06:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :date:from:user-agent:mime-version:to:cc:subject:references
         :in-reply-to:content-transfer-encoding;
        bh=oNxq/T2HPY4+XIAlCcIntezX6BiAJTCfkswtGCnHNGk=;
        b=UYJHncsaPy2/dV/iYe/Hrv5pbhY3LWZwzv0ENpENBJKNLUVg5fKfzDY/C3QFyVx83t
         lHWtu8XPasxLb4MgL7CFrasBk5MfzIgepya97+cFG9cAuOxNDuc0tXOHCEJQ1ceQqtvs
         QuihddbQvZC1zM9uVfGpTw3RZ2pyExc8YI0t6mc1xczWePBLwzMWiaEq3S41EY3CEGMh
         cNdWv8hl59PTeF+Ky1GTFjO35f+1iYH8QIlsX/3Fs/oveoSBFWysWNc4uiTiup71dqop
         Pp1iajUoD69W1XfbqM8/08Cbl/JC0JLjAje0YgCECqwAx6asQawo3Jq2MvDQf+JKzhNG
         /5Ww==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of wei.w.wang@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=wei.w.wang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukchAcY6TFFkIcaih1RlniW7dLJCYThp8atLeQa2LlpCiKCFjxn7
	k2gJpTckYMc17GnvHfnhbczMF2hBxPnzNyOHazZqfdBYgjKvRII1Ea7LSLDQ4rcU2AQ0eeCM576
	48n7YvdbJ9wpw63fLE1tdjKavmcsnBrlDdVtqswOWUTlOq9AqxjHM71RTmS7IZ5bRCg==
X-Received: by 2002:a63:790e:: with SMTP id u14mr24887708pgc.452.1545966409430;
        Thu, 27 Dec 2018 19:06:49 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7TCBqMGrxuyBZGr3Ez4uW5fkNd8N4PmUl0qYRrJxBgkg7js4C1qOkF/YrIv9MP5vnQ4ipE
X-Received: by 2002:a63:790e:: with SMTP id u14mr24887676pgc.452.1545966408533;
        Thu, 27 Dec 2018 19:06:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545966408; cv=none;
        d=google.com; s=arc-20160816;
        b=eozjSnaMMNfCSwSEsI70lmAyGu7WPe9rNRnz2FWCwkNHey8aIGjXhh+vUYR6wyXcl5
         lpRtbro4zTq6dBD6wfTvLppTfZ65WwJ8+CxenJFO4HAh6ksBK600s71dmXgQ3CfCJvlD
         dKlcrj5RH4+zkDflnsEi0Y/Sgyi7RZpSTLAAjdFtd+PEDXVdCbPvwG1HjsCccWV+3yyY
         TelfsrQoZMj8KWfLkB/2oGpRo9WkJu77M4rhpgj5Lb8wMGAwYRhz3U05XjItWLUnX8BD
         2rgh6sCprKS45cOvVs4SztfDxXSvDkuCJjBLgeuhx2rhqMEvo6kHFhfiF2qQb7E/CtMZ
         naiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:references:subject:cc:to
         :mime-version:user-agent:from:date:message-id;
        bh=oNxq/T2HPY4+XIAlCcIntezX6BiAJTCfkswtGCnHNGk=;
        b=wim2zETJTEDfTicDl4JGPcJq7LN2v3e8K22lY0Ss2QeHYoTzu6BLiNQYx67gQSQN0B
         1v/9F238vUiPmYz779/gP3ze5tTd1KOkgVzGGnX/vhIUY0T1Sirnp1h5AQ6zJ1iuwT8P
         eO9IpMnnPsBbQSgy+ljrfRsUYR7OISBZxbKoba1JPhZtZsdaiSUS2z9Ne0p0jo0tVLz8
         ++d9hjJE4ZwK50KvSOBBehtpwuAZHqnySFrOzqMvrxABI/Qt3DuFQU80mbGz7duGd+l3
         h4jyAAaZZJcJeFqwbg8QzsFdefasGr537hXJQn2ZBpm9zqtUWInnEw2/akrpg6Z3Ch5F
         nm6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of wei.w.wang@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=wei.w.wang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id p14si35560560plq.25.2018.12.27.19.06.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Dec 2018 19:06:48 -0800 (PST)
Received-SPF: pass (google.com: domain of wei.w.wang@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of wei.w.wang@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=wei.w.wang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 27 Dec 2018 19:06:47 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,407,1539673200"; 
   d="scan'208";a="307158766"
Received: from unknown (HELO [10.239.13.114]) ([10.239.13.114])
  by fmsmga005.fm.intel.com with ESMTP; 27 Dec 2018 19:06:43 -0800
Message-ID: <5C259485.2030809@intel.com>
Date: Fri, 28 Dec 2018 11:12:05 +0800
From: Wei Wang <wei.w.wang@intel.com>
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:31.0) Gecko/20100101 Thunderbird/31.7.0
MIME-Version: 1.0
To: Christian Borntraeger <borntraeger@de.ibm.com>, 
 virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, 
 virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, 
 linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, 
 akpm@linux-foundation.org, dgilbert@redhat.com
CC: torvalds@linux-foundation.org, pbonzini@redhat.com, 
 liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, 
 quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, 
 peterx@redhat.com, quintela@redhat.com, 
 Cornelia Huck <cohuck@redhat.com>,
 Halil Pasic <pasic@linux.ibm.com>
Subject: Re: [PATCH v37 1/3] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_HINT
References: <1535333539-32420-1-git-send-email-wei.w.wang@intel.com> <1535333539-32420-2-git-send-email-wei.w.wang@intel.com> <49d706f7-a0ee-e571-7d02-bcadac5ce742@de.ibm.com>
In-Reply-To: <49d706f7-a0ee-e571-7d02-bcadac5ce742@de.ibm.com>
Content-Type: text/plain; charset="UTF-8"; format="flowed"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181228031205.jcDEeW2Zdf7_uO18bhl_PxrW3UXM9y-dg7wM-HwcFII@z>

On 12/27/2018 08:03 PM, Christian Borntraeger wrote:
> On 27.08.2018 03:32, Wei Wang wrote:
>>   static int init_vqs(struct virtio_balloon *vb)
>>   {
>> -	struct virtqueue *vqs[3];
>> -	vq_callback_t *callbacks[] = { balloon_ack, balloon_ack, stats_request };
>> -	static const char * const names[] = { "inflate", "deflate", "stats" };
>> -	int err, nvqs;
>> +	struct virtqueue *vqs[VIRTIO_BALLOON_VQ_MAX];
>> +	vq_callback_t *callbacks[VIRTIO_BALLOON_VQ_MAX];
>> +	const char *names[VIRTIO_BALLOON_VQ_MAX];
>> +	int err;
>>
>>   	/*
>> -	 * We expect two virtqueues: inflate and deflate, and
>> -	 * optionally stat.
>> +	 * Inflateq and deflateq are used unconditionally. The names[]
>> +	 * will be NULL if the related feature is not enabled, which will
>> +	 * cause no allocation for the corresponding virtqueue in find_vqs.
>>   	 */
> This might be true for virtio-pci, but it is not for virtio-ccw.

Hi Christian,


Please try the fix patches: https://lkml.org/lkml/2018/12/27/336

Best,
Wei

