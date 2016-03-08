Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id C857F6B0253
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 15:40:54 -0500 (EST)
Received: by mail-io0-f181.google.com with SMTP id m184so41325179iof.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 12:40:54 -0800 (PST)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id 64si6828511ioz.0.2016.03.08.12.40.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 08 Mar 2016 12:40:54 -0800 (PST)
Date: Tue, 8 Mar 2016 14:40:52 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: slub: Ensure that slab_unlock() is atomic
In-Reply-To: <56DEF3D3.6080008@synopsys.com>
Message-ID: <alpine.DEB.2.20.1603081438020.4268@east.gentwo.org>
References: <1457447457-25878-1-git-send-email-vgupta@synopsys.com> <alpine.DEB.2.20.1603080857360.4047@east.gentwo.org> <56DEF3D3.6080008@synopsys.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <vgupta@synopsys.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Noam Camus <noamc@ezchip.com>, stable@vger.kernel.org, linux-kernel@vger.kernel.org, linux-snps-arc@lists.infradead.org

On Tue, 8 Mar 2016, Vineet Gupta wrote:

> # set the bit
> 80543b8e:	ld_s       r2,[r13,0] <--- (A) Finds PG_locked is set
> 80543b90:	or         r3,r2,1    <--- (B) other core unlocks right here
> 80543b94:	st_s       r3,[r13,0] <--- (C) sets PG_locked (overwrites unlock)

Duh. Guess you  need to take the spinlock also in the arch specific
implementation of __bit_spin_unlock(). This is certainly not the only case
in which we use the __ op to unlock.

You need a true atomic op or you need to take the "spinlock" in all
cases where you modify the bit. If you take the lock in __bit_spin_unlock
then the race cannot happen.

> Are you convinced now !

Yes, please fix your arch specific code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
