Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59CFFC282CC
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 17:15:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 099E02146E
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 17:15:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="TzCDwQGj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 099E02146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9FB2F8E0098; Fri,  8 Feb 2019 12:15:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9844B8E0002; Fri,  8 Feb 2019 12:15:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 84C538E0098; Fri,  8 Feb 2019 12:15:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3F9A68E0002
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 12:15:16 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id a9so3100691pla.2
        for <linux-mm@kvack.org>; Fri, 08 Feb 2019 09:15:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=izFIc9YNpqMzrt/FcH2BTUU57hEhVEyMVNJiaHuKRKk=;
        b=pBNDW1p1JhZXVFgtKlHbUl/gho1lzjrAFjK8CljQj9clGSsD34Sp9JTuJwHUtHPPg2
         /UrYGlkv4zX/dAfrKzCR1cs30VeY9Fk01q+Ojx5m9ncM77bWltxYdtb9gl0gsw7xiySY
         A8NpJsS27a7qyVE6JccLuH+9YKdop1W0QgGFRUGewOosYTjVqS3g19lhHXftwN31d+aG
         qtT43H1ag/m7/tX8scJTV75cGSG71K0KP76TZY+lQa757Eu8bPnvrOjKUkXc6kiG6Grp
         xt10Ptll8YECLs+9mjROAHO6OYuRbejSA95bccqUICS4YYGAqFbSax7jT2I4wKqo/f0y
         JfVA==
X-Gm-Message-State: AHQUAuZoe1KHbc4MLKCeGHVEdW/ZMx/JJjLTn9lhzfAMUOqD626yUNA7
	DRAkPZqk51INfSFthcDSDnwR7YUU3uTR4nlB9KHSt7fum/HeigiARjcRqZ6Rv6st0m/f85WtbCU
	AzAXNsy+2WfhPUpZ8hmcN5PwX1pJ7l1uwHwGE1+Ddlzo4SXJkiS08OHIXShkX9Te2bGvzTM4bLg
	JgIorXxhDPv3CJBor8CvPT0HVgxi1iCZcAW0+Hcynb85+WSXsSuPtly5bDmep7G04sS6EpcqcyK
	L/qViAPjBR04BYu/f4rqW0M23MITKvXebusJu9qnSHAONW8hP9XBxSVDwHT5ETp8nWDc54UVKmB
	btxBsCVi6nrjE3ZXqFUey01p8KR1VFusLsMQfKh7mJG1NsMLekT5OCIT8c45IjS+tsR6M5N7W9g
	Q
X-Received: by 2002:a17:902:e18c:: with SMTP id cd12mr22767980plb.279.1549646115753;
        Fri, 08 Feb 2019 09:15:15 -0800 (PST)
X-Received: by 2002:a17:902:e18c:: with SMTP id cd12mr22767890plb.279.1549646114728;
        Fri, 08 Feb 2019 09:15:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549646114; cv=none;
        d=google.com; s=arc-20160816;
        b=xV/FvJ1ULngEVoRKR5ArgHDo8Yjca2Rnk3AGQginwrIwey2u6nyvIvE2zlrwaiYcNy
         C1zdfOHYf8y8JDxfX9uOkjWnBtQ/8eTSRgVBfFx/TdL5wgV1Xbk2uCXyz19LqRRCaPhx
         i4EzMH2pWAdAcNsad9r4zPIdkkwndjrWuVKVd3Mqeou4yws4+dATOs4iUUfux6hA6bQG
         41oKl/ajarCCHW/BwYIw4Qc85cqU4QNSAtL5TnoRCALsdBIDLKdZDjVf5Cva4kqFSWq7
         tAznrKGrYYtj4IEx7fwsKd8JV5Fco7sboAjugrYE0GFqfDRmG3pkSE34GC+FoLCtWh+v
         MjZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=izFIc9YNpqMzrt/FcH2BTUU57hEhVEyMVNJiaHuKRKk=;
        b=M57Seh6e8uqL2Ima2xedwSU1VzjekTVUMkx9MnF8xDLeYQts8DkiU1wEc0iQkCIKNU
         cyvSxoDCRZoECdHKSkPdUuvuugsp0tWXKNA7uT4ZMKNPPdWaHeNsoP8QemEx0QYyRSoH
         X85lkMAx+FLoaWn7dahOV48Ls09e6oDtT4O3V3ncT/WEP+jLr7xqnbz4B5bO8NXdB5Dc
         /H9HDGYBTMfH/tAGl6tyVCuiIeXt84K5cK4iTKo4350S9UFMg120W4U/Ty9gVl5OgmIy
         N3DP8XpL5yMHmoVoGZLMeTaXj9GzfKy/lU5GQBTuLy07G/7tp1rGwCptdk0FOzXKNisY
         aENA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=TzCDwQGj;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p186sor3747691pgp.79.2019.02.08.09.15.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Feb 2019 09:15:14 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=TzCDwQGj;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=izFIc9YNpqMzrt/FcH2BTUU57hEhVEyMVNJiaHuKRKk=;
        b=TzCDwQGjpYtC7fJa5Y+4LxZzqGMq3AauwCE1C9UFWBRR++m+rHWNY1A0wzavWfIO5h
         ezXR5w1c2KDqVcB9Nj+Q4GH5Kkw+fOeymJ5DqL/OlPPY/a9qH6oY7eWDbHanTagSRaHK
         Iqcbji7nyN1bsEgv7n2zuKMpltwh8d/OE+nkkHZZmNiMbwXtnmJlC4z91vqwH/IKYhw2
         uB43pNpx9zbFA2fXgFtrXhRPNbyTiLjIaqVYbiZzv1jp2GGJ6vUeC/kxVIIFY0CaM3DM
         ELN8PZWJqeW7MdofPXPCJGWec9KExNskXn0YUpUyTL2tfMAz3L5f6RD8h98RN9ljXTuG
         4BQA==
X-Google-Smtp-Source: AHgI3IZQiySeY2RzaU27iXwGpVMtLcDLAcVIuCD1Bkfq8xsltQPa1JesGpHQxnjvPLTbCTb2TI2k0tlRZhG4up3iz1w=
X-Received: by 2002:a63:ab0b:: with SMTP id p11mr21880900pgf.264.1549646114047;
 Fri, 08 Feb 2019 09:15:14 -0800 (PST)
MIME-Version: 1.0
References: <b1d210ae-3fc9-c77a-4010-40fb74a61727@lca.pw> <CAAeHK+yzHbLbFe7mtruEG-br9V-LZRC-n6dkq5+mmvLux0gSbg@mail.gmail.com>
 <89b343eb-16ff-1020-2efc-55ca58fafae7@lca.pw> <CAAeHK+zxxk8K3WjGYutmPZr_mX=u7KUcCUYXHi+OgRYMfcvLTg@mail.gmail.com>
 <d8cdc634-0f7d-446e-805a-c5d54e84323a@lca.pw> <59db8d6b-4224-2ec9-09de-909c4338b67a@lca.pw>
In-Reply-To: <59db8d6b-4224-2ec9-09de-909c4338b67a@lca.pw>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Fri, 8 Feb 2019 18:15:02 +0100
Message-ID: <CAAeHK+wsULxYXnGJnQXx9HjZMiU-5jb5ZKC+TuGQihc9L386Xg@mail.gmail.com>
Subject: Re: CONFIG_KASAN_SW_TAGS=y not play well with kmemleak
To: Qian Cai <cai@lca.pw>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, 
	Dmitry Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, Linux-MM <linux-mm@kvack.org>, 
	Catalin Marinas <catalin.marinas@arm.com>
Content-Type: multipart/mixed; boundary="000000000000288e3a0581651aae"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--000000000000288e3a0581651aae
Content-Type: text/plain; charset="UTF-8"

On Fri, Feb 8, 2019 at 5:16 AM Qian Cai <cai@lca.pw> wrote:
>
> Kmemleak is totally busted with CONFIG_KASAN_SW_TAGS=y because most of tracking
> object pointers passed to create_object() have the upper bits set by KASAN.

Hi Qian,

Yeah, the issue is that kmemleak performs a bunch of pointer
comparisons that break when pointers are tagged. Try the attached
patch, it should fix the issue. I don't like the way this patch does
it though, I'll see if I can come up with something better.

Thanks for the report!

> However, even after applied this patch [1] to fix a few things, it still has
> many errors during boot.
>
> https://git.sr.ht/~cai/linux-debug/tree/master/dmesg
>
> What I don't understand is that even the patch did call kasan_reset_tag() in
> paint_ptr(), it still complained on objects with upper bits set which indicates
> that this line did not run.
>
> return (__s64)(value << shift) >> shift;
>
> [   42.462799] kmemleak: Trying to color unknown object at 0xffff80082df80000 as
> Grey
> [   42.470524] CPU: 128 PID: 1 Comm: swapper/0 Not tainted 5.0.0-rc5+ #17
> [   42.477153] Call trace:
> [   42.479639]  dump_backtrace+0x0/0x450
> [   42.483362]  show_stack+0x20/0x2c
> [   42.486733]  __dump_stack+0x20/0x28
> [   42.490276]  dump_stack+0xa0/0xfc
> [   42.493649]  paint_ptr+0xa8/0xf4
> [   42.496934]  kmemleak_not_leak+0xa4/0x15c
> [   42.501013]  init_section_page_ext+0x1bc/0x328
> [   42.505528]  page_ext_init+0x4dc/0x75c
> [   42.509336]  kernel_init_freeable+0x684/0x1104
> [   42.513857]  kernel_init+0x18/0x2a4
> [   42.517407]  ret_from_fork+0x10/0x18
>
> [1]
> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
> index f9d9dc250428..70343d887f34 100644
> --- a/mm/kmemleak.c
> +++ b/mm/kmemleak.c
> @@ -588,7 +588,7 @@ static struct kmemleak_object *create_object(unsigned long
> ptr, size_t size,
>         spin_lock_init(&object->lock);
>         atomic_set(&object->use_count, 1);
>         object->flags = OBJECT_ALLOCATED;
> -       object->pointer = ptr;
> +       object->pointer = (unsigned long)kasan_reset_tag((void *)ptr);
>         object->size = size;
>         object->excess_ref = 0;
>         object->min_count = min_count;
> @@ -748,11 +748,12 @@ static void paint_it(struct kmemleak_object *object, int
> color)
>  static void paint_ptr(unsigned long ptr, int color)
>  {
>         struct kmemleak_object *object;
> +       unsigned long addr = (unsigned long)kasan_reset_tag((void *)ptr);
>
> -       object = find_and_get_object(ptr, 0);
> +       object = find_and_get_object(addr, 0);
>         if (!object) {
>                 kmemleak_warn("Trying to color unknown object at 0x%08lx as %s\n",
> -                             ptr,
> +                             addr,
>                               (color == KMEMLEAK_GREY) ? "Grey" :
>                               (color == KMEMLEAK_BLACK) ? "Black" : "Unknown");
>                 return;
>
>

--000000000000288e3a0581651aae
Content-Type: text/x-patch; charset="US-ASCII"; name="kasan-kmemleak-fix.patch"
Content-Disposition: attachment; filename="kasan-kmemleak-fix.patch"
Content-Transfer-Encoding: base64
Content-ID: <f_jrwb89kb0>
X-Attachment-Id: f_jrwb89kb0

ZGlmZiAtLWdpdCBhL21tL2ttZW1sZWFrLmMgYi9tbS9rbWVtbGVhay5jCmluZGV4IGY5ZDlkYzI1
MDQyOC4uNTM1NGU3NGYwZDE5IDEwMDY0NAotLS0gYS9tbS9rbWVtbGVhay5jCisrKyBiL21tL2tt
ZW1sZWFrLmMKQEAgLTQzNyw2ICs0MzcsOCBAQCBzdGF0aWMgc3RydWN0IGttZW1sZWFrX29iamVj
dCAqbG9va3VwX29iamVjdCh1bnNpZ25lZCBsb25nIHB0ciwgaW50IGFsaWFzKQogewogCXN0cnVj
dCByYl9ub2RlICpyYiA9IG9iamVjdF90cmVlX3Jvb3QucmJfbm9kZTsKIAorCXB0ciA9ICh1bnNp
Z25lZCBsb25nKWthc2FuX3Jlc2V0X3RhZygodm9pZCAqKXB0cik7CisKIAl3aGlsZSAocmIpIHsK
IAkJc3RydWN0IGttZW1sZWFrX29iamVjdCAqb2JqZWN0ID0KIAkJCXJiX2VudHJ5KHJiLCBzdHJ1
Y3Qga21lbWxlYWtfb2JqZWN0LCByYl9ub2RlKTsKQEAgLTU3NSw2ICs1NzcsOCBAQCBzdGF0aWMg
c3RydWN0IGttZW1sZWFrX29iamVjdCAqY3JlYXRlX29iamVjdCh1bnNpZ25lZCBsb25nIHB0ciwg
c2l6ZV90IHNpemUsCiAJc3RydWN0IGttZW1sZWFrX29iamVjdCAqb2JqZWN0LCAqcGFyZW50Owog
CXN0cnVjdCByYl9ub2RlICoqbGluaywgKnJiX3BhcmVudDsKIAorCXB0ciA9ICh1bnNpZ25lZCBs
b25nKWthc2FuX3Jlc2V0X3RhZygodm9pZCAqKXB0cik7CisKIAlvYmplY3QgPSBrbWVtX2NhY2hl
X2FsbG9jKG9iamVjdF9jYWNoZSwgZ2ZwX2ttZW1sZWFrX21hc2soZ2ZwKSk7CiAJaWYgKCFvYmpl
Y3QpIHsKIAkJcHJfd2FybigiQ2Fubm90IGFsbG9jYXRlIGEga21lbWxlYWtfb2JqZWN0IHN0cnVj
dHVyZVxuIik7CkBAIC03MDEsNiArNzA1LDggQEAgc3RhdGljIHZvaWQgZGVsZXRlX29iamVjdF9w
YXJ0KHVuc2lnbmVkIGxvbmcgcHRyLCBzaXplX3Qgc2l6ZSkKIAlzdHJ1Y3Qga21lbWxlYWtfb2Jq
ZWN0ICpvYmplY3Q7CiAJdW5zaWduZWQgbG9uZyBzdGFydCwgZW5kOwogCisJcHRyID0gKHVuc2ln
bmVkIGxvbmcpa2FzYW5fcmVzZXRfdGFnKCh2b2lkICopcHRyKTsKKwogCW9iamVjdCA9IGZpbmRf
YW5kX3JlbW92ZV9vYmplY3QocHRyLCAxKTsKIAlpZiAoIW9iamVjdCkgewogI2lmZGVmIERFQlVH
CkBAIC03ODksNiArNzk1LDggQEAgc3RhdGljIHZvaWQgYWRkX3NjYW5fYXJlYSh1bnNpZ25lZCBs
b25nIHB0ciwgc2l6ZV90IHNpemUsIGdmcF90IGdmcCkKIAlzdHJ1Y3Qga21lbWxlYWtfb2JqZWN0
ICpvYmplY3Q7CiAJc3RydWN0IGttZW1sZWFrX3NjYW5fYXJlYSAqYXJlYTsKIAorCXB0ciA9ICh1
bnNpZ25lZCBsb25nKWthc2FuX3Jlc2V0X3RhZygodm9pZCAqKXB0cik7CisKIAlvYmplY3QgPSBm
aW5kX2FuZF9nZXRfb2JqZWN0KHB0ciwgMSk7CiAJaWYgKCFvYmplY3QpIHsKIAkJa21lbWxlYWtf
d2FybigiQWRkaW5nIHNjYW4gYXJlYSB0byB1bmtub3duIG9iamVjdCBhdCAweCUwOGx4XG4iLApA
QCAtMTMzNCw2ICsxMzQyLDkgQEAgc3RhdGljIHZvaWQgc2Nhbl9ibG9jayh2b2lkICpfc3RhcnQs
IHZvaWQgKl9lbmQsCiAJdW5zaWduZWQgbG9uZyAqZW5kID0gX2VuZCAtIChCWVRFU19QRVJfUE9J
TlRFUiAtIDEpOwogCXVuc2lnbmVkIGxvbmcgZmxhZ3M7CiAKKwlzdGFydCA9ICh1bnNpZ25lZCBs
b25nICopa2FzYW5fcmVzZXRfdGFnKCh2b2lkICopc3RhcnQpOworCWVuZCA9ICh1bnNpZ25lZCBs
b25nICopa2FzYW5fcmVzZXRfdGFnKCh2b2lkICopZW5kKTsKKwogCXJlYWRfbG9ja19pcnFzYXZl
KCZrbWVtbGVha19sb2NrLCBmbGFncyk7CiAJZm9yIChwdHIgPSBzdGFydDsgcHRyIDwgZW5kOyBw
dHIrKykgewogCQlzdHJ1Y3Qga21lbWxlYWtfb2JqZWN0ICpvYmplY3Q7CkBAIC0xMzQ0LDcgKzEz
NTUsNyBAQCBzdGF0aWMgdm9pZCBzY2FuX2Jsb2NrKHZvaWQgKl9zdGFydCwgdm9pZCAqX2VuZCwK
IAkJCWJyZWFrOwogCiAJCWthc2FuX2Rpc2FibGVfY3VycmVudCgpOwotCQlwb2ludGVyID0gKnB0
cjsKKwkJcG9pbnRlciA9ICh1bnNpZ25lZCBsb25nKWthc2FuX3Jlc2V0X3RhZygodm9pZCAqKSpw
dHIpOwogCQlrYXNhbl9lbmFibGVfY3VycmVudCgpOwogCiAJCWlmIChwb2ludGVyIDwgbWluX2Fk
ZHIgfHwgcG9pbnRlciA+PSBtYXhfYWRkcikK
--000000000000288e3a0581651aae--

