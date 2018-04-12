Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1A8706B0007
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 02:28:04 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id t4-v6so3042835plo.9
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 23:28:04 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u130si1834854pgc.86.2018.04.11.23.28.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Apr 2018 23:28:02 -0700 (PDT)
Subject: Re: [LSF/MM TOPIC] CMA and larger page sizes
References: <3a3d724e-4d74-9bd8-60f3-f6896cffac7a@redhat.com>
 <20180126172527.GI5027@dhcp22.suse.cz> <20180404051115.GC6628@js1304-desktop>
 <075843db-ec6e-3822-a60c-ae7487981f09@redhat.com>
 <d88676d9-8f42-2519-56bf-776e46b1180e@suse.cz>
 <b1420dd8-23ae-89e8-3b9d-62663bd69e24@redhat.com>
 <20180412055122.GP23400@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <cca1f71a-3010-46db-231e-bcc0b0796ffd@suse.cz>
Date: Thu, 12 Apr 2018 08:27:59 +0200
MIME-Version: 1.0
In-Reply-To: <20180412055122.GP23400@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, Laura Abbott <labbott@redhat.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On 04/12/2018 07:51 AM, Michal Hocko wrote:
> On Wed 11-04-18 18:06:59, Laura Abbott wrote:
>>
>> I took a look at this a little bit more and while it's true we don't
>> have the unmovable restriction anymore, CMA is still tied to the pageblock
>> size (512MB) because we still have MIGRATE_CMA. I guess making the
>> pageblock smaller seems like the most plausible approach?
> 
> Maybe I am wrong but my take on what Joonsoo said is that we really do
> not have to care about page blocks and MIGRATE_CMA because GFP_MOVABLE
> can be allocated from that migrate type as it is by definition movable.
> The size of the page block shouldn't matter.

Agree, CMA itself doesn't need mark pageblocks with MIGRATE_CMA anymore.
The only user is now hardened usercopy via check_page_span() ->
is_migrate_cma_page(). If we could give up the CMA check there (or
recognize CMA differently?), MIGRATE_CMA could be removed completely,
together with the pageblock alignment code.
