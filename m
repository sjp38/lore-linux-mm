Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f170.google.com (mail-qk0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id 32E536B0261
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 20:25:29 -0400 (EDT)
Received: by qkfc129 with SMTP id c129so101415853qkf.1
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 17:25:29 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d14si30311639qhc.99.2015.07.21.17.25.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jul 2015 17:25:28 -0700 (PDT)
Date: Wed, 22 Jul 2015 08:25:22 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH 3/3] percpu: add macro PCPU_CHUNK_AREA_IN_USE
Message-ID: <20150722002522.GB1834@dhcp-17-102.nay.redhat.com>
References: <1437404130-5188-1-git-send-email-bhe@redhat.com>
 <1437404130-5188-3-git-send-email-bhe@redhat.com>
 <alpine.DEB.2.11.1507201034210.14535@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1507201034210.14535@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: tj@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Christoph,

On 07/20/15 at 10:35am, Christoph Lameter wrote:
> On Mon, 20 Jul 2015, Baoquan He wrote:
> 
> > chunk->map[] contains <offset|in-use flag> of each area. Now add a
> > new macro PCPU_CHUNK_AREA_IN_USE and use it as the in-use flag to
> > replace all magic number '1'.
> 
> Hmmm... This is a bitflag and the code now looks like there is some sort
> of bitmask that were are using. Use bitops or something else that clearly
> implies that a bit is flipped instead?

Thanks for your reviewing and suggesting.

I tried your suggestion and changed to use set_bit/clear_bit to do
instead. It's like this:

@@ -328,8 +329,10 @@ static void pcpu_mem_free(void *ptr, size_t size)
  */
 static int pcpu_count_occupied_pages(struct pcpu_chunk *chunk, int i)
 {
-       int off = chunk->map[i] & ~1;
-       int end = chunk->map[i + 1] & ~1;
+       int off = chunk->map[i];
+       int end = chunk->map[i + 1];
+       clear_bit(PCPU_CHUNK_AREA_IN_USE_BIT, &chunk->map[i]);
+       clear_bit(PCPU_CHUNK_AREA_IN_USE_BIT, &chunk->map[i + 1]);

Looks like code becomes a little redundent. If several different bits in
chunk->map[] have different usage and need several different flags,
bitops maybe better. While now only the lowest bit need be handle, use
bitops kindof too much and can make code a little messy.

You and Tejun may be a little struggled on this change since it make
code longer. Tejun has suggested that at least use a shorter name, like
PCPU_MAP_BUSY. I am going to post v2 to see if it's better.

Thanks
Baoquan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
