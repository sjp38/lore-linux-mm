Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id C68D16B0005
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 08:50:54 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 33so31788093lfw.1
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 05:50:54 -0700 (PDT)
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com. [74.125.82.52])
        by mx.google.com with ESMTPS id fk9si785233wjb.30.2016.07.13.05.50.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 05:50:53 -0700 (PDT)
Received: by mail-wm0-f52.google.com with SMTP id i5so67620522wmg.0
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 05:50:53 -0700 (PDT)
Date: Wed, 13 Jul 2016 14:50:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: System freezes after OOM
Message-ID: <20160713125050.GJ28723@dhcp22.suse.cz>
References: <57837CEE.1010609@redhat.com>
 <f80dc690-7e71-26b2-59a2-5a1557d26713@redhat.com>
 <9be09452-de7f-d8be-fd5d-4a80d1cd1ba3@redhat.com>
 <alpine.LRH.2.02.1607111027080.14327@file01.intranet.prod.int.rdu2.redhat.com>
 <20160712064905.GA14586@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607121907160.24806@file01.intranet.prod.int.rdu2.redhat.com>
 <20160713111006.GF28723@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160713111006.GF28723@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Ondrej Kozina <okozina@redhat.com>, Jerome Marchand <jmarchan@redhat.com>, Stanislav Kozina <skozina@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 13-07-16 13:10:06, Michal Hocko wrote:
> On Tue 12-07-16 19:44:11, Mikulas Patocka wrote:
[...]
> > As long as swapping is in progress, the free memory is below the limit 
> > (because the swapping activity itself consumes any memory over the limit). 
> > And that triggered the OOM killer prematurely.
> 
> I am not sure I understand the last part. Are you saing that we trigger
> OOM because the initiated swapout will not be able to finish the IO thus
> release the page in time?
> 
> The oom detection checks waits for an ongoing writeout if there is no
> reclaim progress and at least half of the reclaimable memory is either
> dirty or under writeback. Pages under swaout are marked as under
> writeback AFAIR. The writeout path (dm-crypt worker in this case) should
> be able to allocate a memory from the mempool, hand over to the crypt
> layer and finish the IO. Is it possible this might take a lot of time?

I am not familiar with the crypto API but from what I understood from
crypt_convert the encryption is done asynchronously. Then I got lost in
the indirection. Who is completing the request and from what kind of
context? Is it possible it wouldn't be runable for a long time?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
