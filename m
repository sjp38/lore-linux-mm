Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5EBD88E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 14:58:10 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id f202so1079720wme.2
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 11:58:10 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id b1si37479318wrj.176.2019.01.11.11.58.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 11:58:08 -0800 (PST)
Date: Fri, 11 Jan 2019 20:58:00 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v7 10/25] ACPI / APEI: Tell firmware the estatus queue
 consumed the records
Message-ID: <20190111195800.GA11723@zn.tnic>
References: <20181203180613.228133-1-james.morse@arm.com>
 <20181203180613.228133-11-james.morse@arm.com>
 <20181211183634.GO27375@zn.tnic>
 <56cfa16b-ece4-76e0-3799-58201f8a4ff1@arm.com>
 <CABo9ajArdbYMOBGPRa185yo9MnKRb0pgS-pHqUNdNS9m+kKO-Q@mail.gmail.com>
 <20190111120322.GD4729@zn.tnic>
 <CABo9ajAk5XNBmNHRRfUb-dQzW7-UOs5826jPkrVz-8zrtMUYkg@mail.gmail.com>
 <20190111174532.GI4729@zn.tnic>
 <32025682-f85a-58ef-7386-7ee23296b944@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <32025682-f85a-58ef-7386-7ee23296b944@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: Tyler Baicar <baicar.tyler@gmail.com>, Linux ACPI <linux-acpi@vger.kernel.org>, kvmarm@lists.cs.columbia.edu, arm-mail-list <linux-arm-kernel@lists.infradead.org>, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>

On Fri, Jan 11, 2019 at 06:25:21PM +0000, James Morse wrote:
> We ack it in the corrupt-record case too, because we are done with the
> memory.

Ok, so the only thing that we need to do unconditionally is ACK in order
to free the memory. Or is there an exception to that set of steps in
error handling?

> I think it is. 18.3.2.8 of ACPI v6.2 (search for Generic Hardware Error Source
> version 2", then below the table):
> * OSPM detects error (via interrupt/exception or polling the block status)
> * OSPM copies the error status block
> * OSPM clears the block status field of the error status block
> * OSPM acknowledges the error via Read Ack register
> 
> The ENOENT case is excluded by 'polling the block status'.

Ok, so we signal the absence of an error record with ENOENT.

        if (!buf_paddr)
                return -ENOENT;

Can that even happen?

Also, in that case, what would happen if we ACK the error anyway? We'd
confuse the firmware?

I sure hope firmware is prepared for spurious ACKs :)

> Unsurprisingly the spec doesn't consider the case that firmware generates
> corrupt records!

You mean the EIO case?

Not surprised at all. But we do not report that record so all good.

Thx.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
