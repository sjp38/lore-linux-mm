Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id E62766B0038
	for <linux-mm@kvack.org>; Sat, 28 Oct 2017 22:39:09 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id l24so9322107pgu.22
        for <linux-mm@kvack.org>; Sat, 28 Oct 2017 19:39:09 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id s8si7261629pgf.663.2017.10.28.19.39.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 28 Oct 2017 19:39:07 -0700 (PDT)
Date: Sat, 28 Oct 2017 19:39:00 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2] fs: fsnotify: account fsnotify metadata to kmemcg
Message-ID: <20171029023900.GA11276@bombadil.infradead.org>
References: <1509128538-50162-1-git-send-email-yang.s@alibaba-inc.com>
 <CAOQ4uxiFA8FDoFU8cNGYoJeiuTFOE9-fgsG4xtnM=9zfAJ+k2g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOQ4uxiFA8FDoFU8cNGYoJeiuTFOE9-fgsG4xtnM=9zfAJ+k2g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amir Goldstein <amir73il@gmail.com>
Cc: Yang Shi <yang.s@alibaba-inc.com>, Jan Kara <jack@suse.cz>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>

On Sat, Oct 28, 2017 at 05:19:36PM +0300, Amir Goldstein wrote:
> <suggest rephrase>
> Due to the current design of kmemcg, the memcg of the process who does the
> allocation gets the accounting, so event allocations get accounted for
> the memcg of
> the event producer process, even though the misbehaving process is the listener.
> The event allocations won't be freed if the producer exits, only if
> the listener exists.
> Nevertheless, it is still better to account event allocations to memcg
> of producer
> process and not to root memcg, because heuristically producer is many
> time in the
> same memcg as the listener. For example, this is the case with listeners inside
> containers that listen on events for files or mounts that are private
> to the container.
> <\suggest rephrase>

Well, if we're nitpicking ...

Due to the current design of kmemcg, the event allocation is accounted to
the memcg of the process producing the event, even though the misbehaving
process is the listener.  The event allocations won't be freed if the
producer exits, only if the listener exits.  Nevertheless, it is still
better to account event allocations to the producer's memcg than the
root memcg, because the producer is frequently in the same memcg as
the listener.  For example, this is the case with listeners inside
containers that listen to events for files or mounts that are private
to the container.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
