Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CAA73C3A59C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 02:14:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F6BD2089E
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 02:14:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="gRe/cawP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F6BD2089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E5CF6B0005; Thu, 15 Aug 2019 22:14:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 299BE6B0006; Thu, 15 Aug 2019 22:14:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1851C6B0007; Thu, 15 Aug 2019 22:14:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0242.hostedemail.com [216.40.44.242])
	by kanga.kvack.org (Postfix) with ESMTP id EC74C6B0005
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 22:14:11 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 955738150
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 02:14:11 +0000 (UTC)
X-FDA: 75826671102.26.girls15_5eb59aaa8402f
X-HE-Tag: girls15_5eb59aaa8402f
X-Filterd-Recvd-Size: 6969
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com [216.228.121.65])
	by imf10.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 02:14:10 +0000 (UTC)
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d5611740000>; Thu, 15 Aug 2019 19:14:12 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 15 Aug 2019 19:14:09 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 15 Aug 2019 19:14:09 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 16 Aug
 2019 02:14:08 +0000
Subject: Re: [RFC PATCH 2/2] mm/gup: introduce vaddr_pin_pages_remote()
From: John Hubbard <jhubbard@nvidia.com>
To: Ira Weiny <ira.weiny@intel.com>, Jan Kara <jack@suse.cz>
CC: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig
	<hch@infradead.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner
	<david@fromorbit.com>, Jason Gunthorpe <jgg@ziepe.ca>,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, LKML
	<linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>,
	<linux-fsdevel@vger.kernel.org>, <linux-rdma@vger.kernel.org>
References: <20190812234950.GA6455@iweiny-DESK2.sc.intel.com>
 <38d2ff2f-4a69-e8bd-8f7c-41f1dbd80fae@nvidia.com>
 <20190813210857.GB12695@iweiny-DESK2.sc.intel.com>
 <a1044a0d-059c-f347-bd68-38be8478bf20@nvidia.com>
 <90e5cd11-fb34-6913-351b-a5cc6e24d85d@nvidia.com>
 <20190814234959.GA463@iweiny-DESK2.sc.intel.com>
 <2cbdf599-2226-99ae-b4d5-8909a0a1eadf@nvidia.com>
 <ac834ac6-39bd-6df9-fca4-70b9520b6c34@nvidia.com>
 <20190815132622.GG14313@quack2.suse.cz>
 <20190815133510.GA21302@quack2.suse.cz>
 <20190815173237.GA30924@iweiny-DESK2.sc.intel.com>
 <b378a363-f523-518d-9864-e2f8e5bd0c34@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <58b75fa9-1272-b683-cb9f-722cc316bf8f@nvidia.com>
Date: Thu, 15 Aug 2019 19:14:08 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <b378a363-f523-518d-9864-e2f8e5bd0c34@nvidia.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1565921652; bh=iNYDYKVrRpRnEo7TyIFnzJma8HwHSIJJS6Onnonm3a4=;
	h=X-PGP-Universal:Subject:From:To:CC:References:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=gRe/cawPAvvKSdqcSXxV0BoA22Rm11wp20pEHyCpKtYaNY3NvTNMCgmALlhtzu63M
	 RIN3ZKEK8vifpbjEEnzFOUyI3Yl6wn/IXsxA7v8zVZr/JTwcIZiqqXqnZVpR31FtxW
	 LRjVeT7m2OURFkEMYaWljedPYFG11RUPR+Kj9YErvI8wkkj12ypFa9D6sllAiLfyfl
	 0Re0SVd3Yol0BqOOIfZwkoSUIa605h9OKR8HgGsdeLCjZCuQngc0TTm5JUNQeqGAFw
	 K/rTsEjAfTKf2rtwDqQpM7AKASOcW56X99NJr0h5hYkPgG0MQNSnrxD6ZasNBIsLz4
	 lcQC4JwZDBA3w==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/15/19 10:41 AM, John Hubbard wrote:
> On 8/15/19 10:32 AM, Ira Weiny wrote:
>> On Thu, Aug 15, 2019 at 03:35:10PM +0200, Jan Kara wrote:
>>> On Thu 15-08-19 15:26:22, Jan Kara wrote:
>>>> On Wed 14-08-19 20:01:07, John Hubbard wrote:
>>>>> On 8/14/19 5:02 PM, John Hubbard wrote:
...
>> Ok just to make this clear I threw up my current tree with your patches here:
>>
>> https://github.com/weiny2/linux-kernel/commits/mmotm-rdmafsdax-b0-v4
>>
>> I'm talking about dropping the final patch:
>> 05fd2d3afa6b rdma/umem_odp: Use vaddr_pin_pages_remote() in ODP
>>
>> The other 2 can stay.  I split out the *_remote() call.  We don't have a user
>> but I'll keep it around for a bit.
>>
>> This tree is still WIP as I work through all the comments.  So I've not changed
>> names or variable types etc...  Just wanted to settle this.
>>
> 
> Right. And now that ODP is not a user, I'll take a quick look through my other
> call site conversions and see if I can find an easy one, to include here as
> the first user of vaddr_pin_pages_remote(). I'll send it your way if that
> works out.
> 

OK, there was only process_vm_access.c, plus (sort of) Bharath's sgi-gru
patch, maybe eventually [1].  But looking at process_vm_access.c, I think 
it is one of the patches that is no longer applicable, and I can just
drop it entirely...I'd welcome a second opinion on that...

So we might be all out of potential users for vaddr_pin_pages_remote()!

For quick reference, it looks like this:
 
diff --git a/mm/process_vm_access.c b/mm/process_vm_access.c
index 357aa7bef6c0..4d29d54ec93f 100644
--- a/mm/process_vm_access.c
+++ b/mm/process_vm_access.c
@@ -96,7 +96,7 @@ static int process_vm_rw_single_vec(unsigned long addr,
                flags |= FOLL_WRITE;
 
        while (!rc && nr_pages && iov_iter_count(iter)) {
-               int pages = min(nr_pages, max_pages_per_loop);
+               int pinned_pages = min(nr_pages, max_pages_per_loop);
                int locked = 1;
                size_t bytes;
 
@@ -106,14 +106,15 @@ static int process_vm_rw_single_vec(unsigned long addr,
                 * current/current->mm
                 */
                down_read(&mm->mmap_sem);
-               pages = get_user_pages_remote(task, mm, pa, pages, flags,
-                                             process_pages, NULL, &locked);
+               pinned_pages = get_user_pages_remote(task, mm, pa, pinned_pages,
+                                                    flags, process_pages, NULL,
+                                                    &locked);
                if (locked)
                        up_read(&mm->mmap_sem);
-               if (pages <= 0)
+               if (pinned_pages <= 0)
                        return -EFAULT;
 
-               bytes = pages * PAGE_SIZE - start_offset;
+               bytes = pinned_pages * PAGE_SIZE - start_offset;
                if (bytes > len)
                        bytes = len;
 
@@ -122,10 +123,9 @@ static int process_vm_rw_single_vec(unsigned long addr,
                                         vm_write);
                len -= bytes;
                start_offset = 0;
-               nr_pages -= pages;
-               pa += pages * PAGE_SIZE;
-               while (pages)
-                       put_page(process_pages[--pages]);
+               nr_pages -= pinned_pages;
+               pa += pinned_pages * PAGE_SIZE;
+               put_user_pages(process_pages, pinned_pages);
        }
 
        return rc;


[1] https://lore.kernel.org/r/1565379497-29266-2-git-send-email-linux.bhar@gmail.com

thanks,
-- 
John Hubbard
NVIDIA

