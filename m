Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B00FA6B0262
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 09:44:34 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id x83so35354383wma.2
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 06:44:34 -0700 (PDT)
Received: from mail-wm0-x22d.google.com (mail-wm0-x22d.google.com. [2a00:1450:400c:c09::22d])
        by mx.google.com with ESMTPS id 124si28083741wmq.81.2016.07.13.06.44.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 06:44:33 -0700 (PDT)
Received: by mail-wm0-x22d.google.com with SMTP id o80so70030962wme.1
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 06:44:33 -0700 (PDT)
Subject: Re: System freezes after OOM
References: <57837CEE.1010609@redhat.com>
 <f80dc690-7e71-26b2-59a2-5a1557d26713@redhat.com>
 <9be09452-de7f-d8be-fd5d-4a80d1cd1ba3@redhat.com>
 <alpine.LRH.2.02.1607111027080.14327@file01.intranet.prod.int.rdu2.redhat.com>
 <20160712064905.GA14586@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607121907160.24806@file01.intranet.prod.int.rdu2.redhat.com>
 <20160713111006.GF28723@dhcp22.suse.cz>
 <20160713125050.GJ28723@dhcp22.suse.cz>
From: Milan Broz <gmazyland@gmail.com>
Message-ID: <97c60afe-d922-ce4c-3a5c-5b15bf0fe2da@gmail.com>
Date: Wed, 13 Jul 2016 15:44:31 +0200
MIME-Version: 1.0
In-Reply-To: <20160713125050.GJ28723@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Mikulas Patocka <mpatocka@redhat.com>
Cc: Ondrej Kozina <okozina@redhat.com>, Jerome Marchand <jmarchan@redhat.com>, Stanislav Kozina <skozina@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, device-mapper development <dm-devel@redhat.com>

On 07/13/2016 02:50 PM, Michal Hocko wrote:
> On Wed 13-07-16 13:10:06, Michal Hocko wrote:
>> On Tue 12-07-16 19:44:11, Mikulas Patocka wrote:
> [...]
>>> As long as swapping is in progress, the free memory is below the limit 
>>> (because the swapping activity itself consumes any memory over the limit). 
>>> And that triggered the OOM killer prematurely.
>>
>> I am not sure I understand the last part. Are you saing that we trigger
>> OOM because the initiated swapout will not be able to finish the IO thus
>> release the page in time?
>>
>> The oom detection checks waits for an ongoing writeout if there is no
>> reclaim progress and at least half of the reclaimable memory is either
>> dirty or under writeback. Pages under swaout are marked as under
>> writeback AFAIR. The writeout path (dm-crypt worker in this case) should
>> be able to allocate a memory from the mempool, hand over to the crypt
>> layer and finish the IO. Is it possible this might take a lot of time?
> 
> I am not familiar with the crypto API but from what I understood from
> crypt_convert the encryption is done asynchronously. Then I got lost in
> the indirection. Who is completing the request and from what kind of
> context? Is it possible it wouldn't be runable for a long time?

If you mean crypt_convert in dm-crypt, then it can do asynchronous completion
but usually (with AES-NI ans sw implementations) it run the operation completely
synchronously.
Asynchronous processing is quite rare, usually only on some specific hardware
crypto accelerators.

Once the encryption is finished, the cloned bio is sent to the block
layer for processing.
(There is also some magic with sorting writes but Mikulas knows this better.)

Milan
p.s. I added cc to dm-devel, some dmcrypt people reads only this list.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
