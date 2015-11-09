Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id B647D6B0258
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 18:20:59 -0500 (EST)
Received: by wmww144 with SMTP id w144so53404731wmw.0
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 15:20:59 -0800 (PST)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id 62si19880864wml.79.2015.11.09.15.20.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Nov 2015 15:20:58 -0800 (PST)
Received: by wmww144 with SMTP id w144so96470732wmw.1
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 15:20:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1444253335-5811-1-git-send-email-labbott@fedoraproject.org>
References: <1444253335-5811-1-git-send-email-labbott@fedoraproject.org>
Date: Mon, 9 Nov 2015 15:20:58 -0800
Message-ID: <CA+8MBbLGdYfQRPnVmT=te1y3C7PhCcXqbDGXb7LtqvCWTA+vDQ@mail.gmail.com>
Subject: Re: [PATCHv4] mm: Don't offset memmap for flatmem
From: Tony Luck <tony.luck@gmail.com>
Content-Type: multipart/mixed; boundary=001a114449f07ffad7052423d893
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@fedoraproject.org>
Cc: Srinivas Kandagatla <srinivas.kandagatla@linaro.org>, Vlastimil Babka <vbabka@suse.cz>, Bjorn Andersson <bjorn.andersson@sonymobile.com>, Laura Abbott <laura@labbott.name>, Santosh Shilimkar <ssantosh@kernel.org>, Russell King <rmk@arm.linux.org.uk>, Kevin Hilman <khilman@linaro.org>, Arnd Bergman <arnd@arndb.de>, Stephen Boyd <sboyd@codeaurora.org>, Andy Gross <agross@codeaurora.org>, Mel Gorman <mgorman@suse.de>, Steven Rostedt <rostedt@goodmis.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Laura Abbott <lauraa@codeaurora.org>

--001a114449f07ffad7052423d893
Content-Type: text/plain; charset=UTF-8

> @@ -4984,9 +4987,9 @@ static void __init_refok alloc_node_mem_map(struct pglist_data *pgdat)
>          */
>         if (pgdat == NODE_DATA(0)) {
>                 mem_map = NODE_DATA(0)->node_mem_map;
> -#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
> +#if defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP) || defined(CONFIG_FLATMEM)
>                 if (page_to_pfn(mem_map) != pgdat->node_start_pfn)
> -                       mem_map -= (pgdat->node_start_pfn - ARCH_PFN_OFFSET);
> +                       mem_map -= offset;
>  #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
>         }
>  #endif

This piece breaks ia64.  See the comment earlier in the function
that "ia64 gets its own node_mem_map" ... so we skip the initialization
of offset ... and arrive down here and just subtract "0" from mem_map.

Attached patch fixes ia64 ... does ARM still work if this is applied?

-Tony

--001a114449f07ffad7052423d893
Content-Type: text/x-patch; charset=US-ASCII; name="fixia64.patch"
Content-Disposition: attachment; filename="fixia64.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_igskngzk0

ZGlmZiAtLWdpdCBhL21tL3BhZ2VfYWxsb2MuYyBiL21tL3BhZ2VfYWxsb2MuYwppbmRleCAyMDhl
NGM3ZTc3MWIuLmM0NzA1MDk1YTUxNiAxMDA2NDQKLS0tIGEvbW0vcGFnZV9hbGxvYy5jCisrKyBi
L21tL3BhZ2VfYWxsb2MuYwpAQCAtNTI2Niw2ICs1MjY2LDcgQEAgc3RhdGljIHZvaWQgX19wYWdp
bmdpbml0IGZyZWVfYXJlYV9pbml0X2NvcmUoc3RydWN0IHBnbGlzdF9kYXRhICpwZ2RhdCkKIAog
c3RhdGljIHZvaWQgX19pbml0X3JlZm9rIGFsbG9jX25vZGVfbWVtX21hcChzdHJ1Y3QgcGdsaXN0
X2RhdGEgKnBnZGF0KQogeworCXVuc2lnbmVkIGxvbmcgX19tYXliZV91bnVzZWQgc3RhcnQgPSAw
OwogCXVuc2lnbmVkIGxvbmcgX19tYXliZV91bnVzZWQgb2Zmc2V0ID0gMDsKIAogCS8qIFNraXAg
ZW1wdHkgbm9kZXMgKi8KQEAgLTUyNzMsOSArNTI3NCwxMSBAQCBzdGF0aWMgdm9pZCBfX2luaXRf
cmVmb2sgYWxsb2Nfbm9kZV9tZW1fbWFwKHN0cnVjdCBwZ2xpc3RfZGF0YSAqcGdkYXQpCiAJCXJl
dHVybjsKIAogI2lmZGVmIENPTkZJR19GTEFUX05PREVfTUVNX01BUAorCXN0YXJ0ID0gcGdkYXQt
Pm5vZGVfc3RhcnRfcGZuICYgfihNQVhfT1JERVJfTlJfUEFHRVMgLSAxKTsKKwlvZmZzZXQgPSBw
Z2RhdC0+bm9kZV9zdGFydF9wZm4gLSBzdGFydDsKIAkvKiBpYTY0IGdldHMgaXRzIG93biBub2Rl
X21lbV9tYXAsIGJlZm9yZSB0aGlzLCB3aXRob3V0IGJvb3RtZW0gKi8KIAlpZiAoIXBnZGF0LT5u
b2RlX21lbV9tYXApIHsKLQkJdW5zaWduZWQgbG9uZyBzaXplLCBzdGFydCwgZW5kOworCQl1bnNp
Z25lZCBsb25nIHNpemUsIGVuZDsKIAkJc3RydWN0IHBhZ2UgKm1hcDsKIAogCQkvKgpAQCAtNTI4
NCw3ICs1Mjg3LDYgQEAgc3RhdGljIHZvaWQgX19pbml0X3JlZm9rIGFsbG9jX25vZGVfbWVtX21h
cChzdHJ1Y3QgcGdsaXN0X2RhdGEgKnBnZGF0KQogCQkgKiBmb3IgdGhlIGJ1ZGR5IGFsbG9jYXRv
ciB0byBmdW5jdGlvbiBjb3JyZWN0bHkuCiAJCSAqLwogCQlzdGFydCA9IHBnZGF0LT5ub2RlX3N0
YXJ0X3BmbiAmIH4oTUFYX09SREVSX05SX1BBR0VTIC0gMSk7Ci0JCW9mZnNldCA9IHBnZGF0LT5u
b2RlX3N0YXJ0X3BmbiAtIHN0YXJ0OwogCQllbmQgPSBwZ2RhdF9lbmRfcGZuKHBnZGF0KTsKIAkJ
ZW5kID0gQUxJR04oZW5kLCBNQVhfT1JERVJfTlJfUEFHRVMpOwogCQlzaXplID0gIChlbmQgLSBz
dGFydCkgKiBzaXplb2Yoc3RydWN0IHBhZ2UpOwo=
--001a114449f07ffad7052423d893--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
