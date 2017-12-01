Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B33BC6B0260
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 03:05:02 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id z1so6863924pfl.9
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 00:05:02 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id c21si4586330pls.397.2017.12.01.00.05.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Dec 2017 00:05:01 -0800 (PST)
Message-ID: <5A210DA2.7030101@intel.com>
Date: Fri, 01 Dec 2017 16:06:58 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v18 10/10] virtio-balloon: don't report free pages when
 page poisoning is enabled
References: <1511963726-34070-1-git-send-email-wei.w.wang@intel.com>	<1511963726-34070-11-git-send-email-wei.w.wang@intel.com> <201711301945.HJD69236.OSMQtOFHOJLVFF@I-love.SAKURA.ne.jp>
In-Reply-To: <201711301945.HJD69236.OSMQtOFHOJLVFF@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, virtio-dev@lists.oasis-open.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org

On 11/30/2017 06:45 PM, Tetsuo Handa wrote:
> Wei Wang wrote:
>> @@ -652,7 +652,9 @@ static void report_free_page(struct work_struct *work)
>>   	/* Start by sending the obtained cmd id to the host with an outbuf */
>>   	send_one_desc(vb, vb->free_page_vq, virt_to_phys(&vb->start_cmd_id),
>>   		      sizeof(uint32_t), false, true, false);
>> -	walk_free_mem_block(vb, 0, &virtio_balloon_send_free_pages);
>> +	if (!(page_poisoning_enabled() &&
>> +	    !IS_ENABLED(CONFIG_PAGE_POISONING_NO_SANITY)))
> I think that checking IS_ENABLED() before checking page_poisoning_enabled()
> would generate better code, for IS_ENABLED() is build-time constant while
> page_poisoning_enabled() is a function which the compiler assumes that we
> need to call page_poisoning_enabled() even if IS_ENABLED() is known to be 0.
>
> 	if (IS_ENABLED(CONFIG_PAGE_POISONING_NO_SANITY) ||
> 	    !page_poisoning_enabled())
>
>

Agree, thanks.

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
