Return-Path: <SRS0=dGUi=PF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89CC8C43387
	for <linux-mm@archiver.kernel.org>; Fri, 28 Dec 2018 06:36:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 36CDB208E4
	for <linux-mm@archiver.kernel.org>; Fri, 28 Dec 2018 06:36:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36CDB208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 726B38E0033; Fri, 28 Dec 2018 01:36:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6FDB38E0001; Fri, 28 Dec 2018 01:36:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 614688E0033; Fri, 28 Dec 2018 01:36:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 231A88E0001
	for <linux-mm@kvack.org>; Fri, 28 Dec 2018 01:36:26 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id m3so22644553pfj.14
        for <linux-mm@kvack.org>; Thu, 27 Dec 2018 22:36:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :date:from:user-agent:mime-version:to:cc:subject:references
         :in-reply-to:content-transfer-encoding;
        bh=lsXK23dY/JXgKOo8tBzVcrl1k8jDNuM8wtmUeWrgOrQ=;
        b=j9h/FK9TDWCogyTDBoJCHQZ/lTph+8yJC6KEBWN7Vl89Ih5fuGaztfdz0/G0B+REqL
         eiPF+AOqXd2W8y2GozslfqsIzRGBAmxM/EV1tR5y/lhI5d9Pe2AnoCjqAm9Q7SxXzn1Y
         +WhrirdNrUYluefnmUosV/psGndM9Mcp3UqtSNAjUQeT9uJa19eXTGNpoF/i9m4DqY/5
         /gVfo8405gTI0mL7q4g+zAldFSaUPbeYzGvp+EBSAKEYyO4t1TjcgKQo0fGVItum1MQf
         P2nK3Pka4Tv5ImBPuu57xGcSAtucUNuwC294jQQxIDxkErGhCFGI6s4Heq7npwrlzbvW
         pqcQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of wei.w.wang@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=wei.w.wang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukfxj4ZxH8o9yHYvJpr5PoreU3uZK0zMYbMg+TC33f7g2SfwRmhv
	ErFmyPgOUxBz5v6jz9p7cgriUVb5zoj/Ny/Tu+M2tUFcYjUiNNXe4E3uh8aJZeTn4aNc4v7mkbG
	xvAmwm7PgJspY9bEROkRTssuai39UJ7CDWVwW0qMUdzL7NQSb5kOsfA58z3C2Bn8wZw==
X-Received: by 2002:a65:6392:: with SMTP id h18mr25687879pgv.107.1545978985730;
        Thu, 27 Dec 2018 22:36:25 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4L7N2aa4DUNiMeiehLYTqgWrVWdZvNJT0qLsmVkoH2Eii4myLWqhWB68kCrPflEMSnhA4e
X-Received: by 2002:a65:6392:: with SMTP id h18mr25687849pgv.107.1545978984697;
        Thu, 27 Dec 2018 22:36:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545978984; cv=none;
        d=google.com; s=arc-20160816;
        b=Iwo6xQOc+g2jbmnalpjuZEGGKdS7DeKvumnxASxvxZvULXA6H+GHVt5qJdRlC51MJD
         IKDLTFJ5Qr/zSEE1jyEZbIHMK0XBw8UkRyDmmlLuUAHOOyfViDKo+UFVI1EvF1vudng8
         9AY5V0JhH7/0Z8vUtY81ty7T8lyKo8fRbtJOctaMfBedTIXyize0ybjLNCkHMOAl/Y+t
         g3Uaf1OZ7HZAvC4+cI8WEHPoEgzhvarTIcBSPKEyA7hWMOq7mBGUlb0WEDxXZQX53ZUM
         WRHEwIGHFF5xKRXsM4++J+iu+9xxcH2d5A+beA7+J29IOX8NIxplp6zhyR+QQr0cB8MT
         OgDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:references:subject:cc:to
         :mime-version:user-agent:from:date:message-id;
        bh=lsXK23dY/JXgKOo8tBzVcrl1k8jDNuM8wtmUeWrgOrQ=;
        b=QTl6tU2etvx0i1GAQNVjlWLxOYVb/F4S0iF2y0iyBUMmHqAJQer390aFMz1s9W4H0S
         K0DrVUX0pKIpnP5o23GzSt//HlLS6VX3yL9QtPoIe/UiitnFCvVd9YpZi93Qe5WNhroa
         pW+1j+K6bLBijYIfrSyfU8p/6/2NkaO7YadV4XXc6z3HvAfSpQScE97ygRC7GFLoGJKn
         blXzXDG2O6nS1XjuP3mn+ToB6xN+aKMIwO8DZrN4rWVKj51UdiI+g18/rChbzvcCALTY
         ihhWpQOXBXzSmzXUl6e0f5OAN1dXATXMvdi9atuqI8NxNMUcVQ4eCzg2NMOgWazfJQlP
         Kurg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of wei.w.wang@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=wei.w.wang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id y5si35149463pgk.49.2018.12.27.22.36.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Dec 2018 22:36:24 -0800 (PST)
Received-SPF: pass (google.com: domain of wei.w.wang@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of wei.w.wang@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=wei.w.wang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 27 Dec 2018 22:36:23 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,408,1539673200"; 
   d="scan'208";a="131208853"
Received: from unknown (HELO [10.239.13.114]) ([10.239.13.114])
  by fmsmga004.fm.intel.com with ESMTP; 27 Dec 2018 22:36:20 -0800
Message-ID: <5C25C5A5.4080706@intel.com>
Date: Fri, 28 Dec 2018 14:41:41 +0800
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
 Halil Pasic <pasic@linux.ibm.com>,
 Cornelia Huck <cohuck@redhat.com>
Subject: Re: [PATCH v37 0/3] Virtio-balloon: support free page reporting
References: <1535333539-32420-1-git-send-email-wei.w.wang@intel.com> <0661b05a-d9d0-d374-44e8-2583463e94c2@de.ibm.com> <de167161-b586-6aee-d6a5-a90d47bbe1d4@de.ibm.com> <e79b5c3d-aa89-6b99-00b1-c92c85fe214c@de.ibm.com>
In-Reply-To: <e79b5c3d-aa89-6b99-00b1-c92c85fe214c@de.ibm.com>
Content-Type: text/plain; charset="UTF-8"; format="flowed"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181228064141.VdlKaIh8eDCsMgt4ifA9e9o6jgUONNPcdelHCvDqjYo@z>

On 12/27/2018 08:17 PM, Christian Borntraeger wrote:
>
> On 27.12.2018 12:59, Christian Borntraeger wrote:
>> On 27.12.2018 12:31, Christian Borntraeger wrote:
>>> This patch triggers random crashes in the guest kernel on s390 early during boot.
>>> No migration and no setting of the balloon is involved.
>>>
>> Adding Conny and Halil,
>>
>> As the QEMU provides no PAGE_HINT feature yet, this quick hack makes the
>> guest boot fine again:
>>
>>
>> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
>> index 728ecd1eea305..aa2e1864c5736 100644
>> --- a/drivers/virtio/virtio_balloon.c
>> +++ b/drivers/virtio/virtio_balloon.c
>> @@ -492,7 +492,7 @@ static int init_vqs(struct virtio_balloon *vb)
>>                  callbacks[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
>>          }
>>   
>> -       err = vb->vdev->config->find_vqs(vb->vdev, VIRTIO_BALLOON_VQ_MAX,
>> +       err = vb->vdev->config->find_vqs(vb->vdev, 3, //VIRTIO_BALLOON_VQ_MAX,
>>                                           vqs, callbacks, names, NULL, NULL);
>>          if (err)
>>                  return err;
>>
>>
>> To me it looks like that virtio_ccw_find_vqs will abort if any of the virtqueues
>> that it is been asked for does not exist (including the earlier ones).
>>
> This "hack" makes the random crashes go away, but the balloon interface itself
> does not work. (setting the value to anything will hang the guest).
> As patch 1 also modifies the main path, there seem to be additional issues, maybe
> endianess
>
> Looking at things like
>
> +		vb->cmd_id_received = VIRTIO_BALLOON_CMD_ID_STOP;
> +		vb->cmd_id_active = cpu_to_virtio32(vb->vdev,
> +						  VIRTIO_BALLOON_CMD_ID_STOP);
> +		vb->cmd_id_stop = cpu_to_virtio32(vb->vdev,
> +						  VIRTIO_BALLOON_CMD_ID_STOP);
>
>
> Why is cmd_id_received not using cpu_to_virtio32?
>

That conversion is only needed when we need to send the value to the device.
cmd_id_received doesn't need to be sent to the device.

Best,
Wei


