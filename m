Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 587176B0031
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 20:46:17 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id q10so1208633pdj.21
        for <linux-mm@kvack.org>; Fri, 02 Aug 2013 17:46:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1375408621-16563-2-git-send-email-iamjoonsoo.kim@lge.com>
References: <1375408621-16563-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1375408621-16563-2-git-send-email-iamjoonsoo.kim@lge.com>
Date: Sat, 3 Aug 2013 08:46:16 +0800
Message-ID: <CANBD6kHK+7rDN5VKDqiGp4T7i1vAXF04pjpdNsm0q+GAbzwKJQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm, vmalloc: use well-defined find_last_bit() func
From: Yanfei Zhang <zhangyanfei.yes@gmail.com>
Content-Type: multipart/alternative; boundary=047d7b10cce91f3cd704e30067db
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Joonsoo Kim <js1304@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>

--047d7b10cce91f3cd704e30067db
Content-Type: text/plain; charset=UTF-8

On Friday, August 2, 2013, Joonsoo Kim wrote:

> Our intention in here is to find last_bit within the region to flush.
> There is well-defined function, find_last_bit() for this purpose and
> it's performance may be slightly better than current implementation.
> So change it.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com <javascript:;>>


Looks reasonable.

Acked-by: Zhang Yanfei
<zhangyanfei@cn.fujitsu.com<https://mail.google.com/mail/mu/mp/219/?source=nap&hr=1&hl=en>
>


>
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index d23c432..93d3182 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1016,15 +1016,16 @@ void vm_unmap_aliases(void)
>
>                 rcu_read_lock();
>                 list_for_each_entry_rcu(vb, &vbq->free, free_list) {
> -                       int i;
> +                       int i, j;
>
>                         spin_lock(&vb->lock);
>                         i = find_first_bit(vb->dirty_map, VMAP_BBMAP_BITS);
> -                       while (i < VMAP_BBMAP_BITS) {
> +                       if (i < VMAP_BBMAP_BITS) {
>                                 unsigned long s, e;
> -                               int j;
> -                               j = find_next_zero_bit(vb->dirty_map,
> -                                       VMAP_BBMAP_BITS, i);
> +
> +                               j = find_last_bit(vb->dirty_map,
> +                                                       VMAP_BBMAP_BITS);
> +                               j = j + 1; /* need exclusive index */
>
>                                 s = vb->va->va_start + (i << PAGE_SHIFT);
>                                 e = vb->va->va_start + (j << PAGE_SHIFT);
> @@ -1034,10 +1035,6 @@ void vm_unmap_aliases(void)
>                                         start = s;
>                                 if (e > end)
>                                         end = e;
> -
> -                               i = j;
> -                               i = find_next_bit(vb->dirty_map,
> -                                                       VMAP_BBMAP_BITS,
> i);
>                         }
>                         spin_unlock(&vb->lock);
>                 }
> --
> 1.7.9.5
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org <javascript:;>
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>

--047d7b10cce91f3cd704e30067db
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: base64

T24gRnJpZGF5LCBBdWd1c3QgMiwgMjAxMywgSm9vbnNvbyBLaW0gIHdyb3RlOjxicj48YmxvY2tx
dW90ZSBjbGFzcz0iZ21haWxfcXVvdGUiIHN0eWxlPSJtYXJnaW46MCAwIDAgLjhleDtib3JkZXIt
bGVmdDoxcHggI2NjYyBzb2xpZDtwYWRkaW5nLWxlZnQ6MWV4Ij5PdXIgaW50ZW50aW9uIGluIGhl
cmUgaXMgdG8gZmluZCBsYXN0X2JpdCB3aXRoaW4gdGhlIHJlZ2lvbiB0byBmbHVzaC48YnI+DQoN
ClRoZXJlIGlzIHdlbGwtZGVmaW5lZCBmdW5jdGlvbiwgZmluZF9sYXN0X2JpdCgpIGZvciB0aGlz
IHB1cnBvc2UgYW5kPGJyPg0KaXQmIzM5O3MgcGVyZm9ybWFuY2UgbWF5IGJlIHNsaWdodGx5IGJl
dHRlciB0aGFuIGN1cnJlbnQgaW1wbGVtZW50YXRpb24uPGJyPg0KU28gY2hhbmdlIGl0Ljxicj4N
Cjxicj4NClNpZ25lZC1vZmYtYnk6IEpvb25zb28gS2ltICZsdDs8YSBocmVmPSJqYXZhc2NyaXB0
OjsiIG9uY2xpY2s9Il9lKGV2ZW50LCAmIzM5O2N2bWwmIzM5OywgJiMzOTtpYW1qb29uc29vLmtp
bUBsZ2UuY29tJiMzOTspIj5pYW1qb29uc29vLmtpbUBsZ2UuY29tPC9hPiZndDs8L2Jsb2NrcXVv
dGU+PGRpdj48YnI+PC9kaXY+PGRpdj5Mb29rcyByZWFzb25hYmxlLjxzcGFuPjwvc3Bhbj48L2Rp
dj4NCjxkaXY+PGJyPjwvZGl2PjxkaXY+PGZvbnQ+PHNwYW4gc3R5bGU9ImxpbmUtaGVpZ2h0Om5v
cm1hbDtiYWNrZ3JvdW5kLWNvbG9yOnJnYmEoMjU1LDI1NSwyNTUsMCkiPkFja2VkLWJ5OiBaaGFu
ZyBZYW5mZWkgJmx0OzxhIGhyZWY9Imh0dHBzOi8vbWFpbC5nb29nbGUuY29tL21haWwvbXUvbXAv
MjE5Lz9zb3VyY2U9bmFwJmFtcDtocj0xJmFtcDtobD1lbiIgdGFyZ2V0PSJfYmxhbmsiPnpoYW5n
eWFuZmVpQGNuLmZ1aml0c3UuY29tPC9hPiZndDs8L3NwYW4+PC9mb250PjwvZGl2Pg0KPGRpdj7C
oDwvZGl2PjxibG9ja3F1b3RlIGNsYXNzPSJnbWFpbF9xdW90ZSIgc3R5bGU9Im1hcmdpbjowIDAg
MCAuOGV4O2JvcmRlci1sZWZ0OjFweCAjY2NjIHNvbGlkO3BhZGRpbmctbGVmdDoxZXgiPg0KPGJy
Pg0KZGlmZiAtLWdpdCBhL21tL3ZtYWxsb2MuYyBiL21tL3ZtYWxsb2MuYzxicj4NCmluZGV4IGQy
M2M0MzIuLjkzZDMxODIgMTAwNjQ0PGJyPg0KLS0tIGEvbW0vdm1hbGxvYy5jPGJyPg0KKysrIGIv
bW0vdm1hbGxvYy5jPGJyPg0KQEAgLTEwMTYsMTUgKzEwMTYsMTYgQEAgdm9pZCB2bV91bm1hcF9h
bGlhc2VzKHZvaWQpPGJyPg0KPGJyPg0KwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgcmN1X3JlYWRf
bG9jaygpOzxicj4NCsKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIGxpc3RfZm9yX2VhY2hfZW50cnlf
cmN1KHZiLCAmYW1wO3ZicS0mZ3Q7ZnJlZSwgZnJlZV9saXN0KSB7PGJyPg0KLSDCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCBpbnQgaTs8YnI+DQorIMKgIMKgIMKgIMKgIMKgIMKgIMKg
IMKgIMKgIMKgIMKgIGludCBpLCBqOzxicj4NCjxicj4NCsKgIMKgIMKgIMKgIMKgIMKgIMKgIMKg
IMKgIMKgIMKgIMKgIHNwaW5fbG9jaygmYW1wO3ZiLSZndDtsb2NrKTs8YnI+DQrCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCBpID0gZmluZF9maXJzdF9iaXQodmItJmd0O2RpcnR5
X21hcCwgVk1BUF9CQk1BUF9CSVRTKTs8YnI+DQotIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKg
IMKgIMKgIHdoaWxlIChpICZsdDsgVk1BUF9CQk1BUF9CSVRTKSB7PGJyPg0KKyDCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCBpZiAoaSAmbHQ7IFZNQVBfQkJNQVBfQklUUykgezxicj4N
CsKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIHVuc2lnbmVk
IGxvbmcgcywgZTs8YnI+DQotIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKg
IMKgIMKgIGludCBqOzxicj4NCi0gwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqAgaiA9IGZpbmRfbmV4dF96ZXJvX2JpdCh2Yi0mZ3Q7ZGlydHlfbWFwLDxicj4NCi0g
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
Vk1BUF9CQk1BUF9CSVRTLCBpKTs8YnI+DQorPGJyPg0KKyDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCBqID0gZmluZF9sYXN0X2JpdCh2Yi0mZ3Q7ZGlydHlfbWFw
LDxicj4NCisgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgVk1BUF9CQk1BUF9CSVRTKTs8YnI+DQor
IMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIGogPSBqICsgMTsg
LyogbmVlZCBleGNsdXNpdmUgaW5kZXggKi88YnI+DQo8YnI+DQrCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCBzID0gdmItJmd0O3ZhLSZndDt2YV9zdGFydCAr
IChpICZsdDsmbHQ7IFBBR0VfU0hJRlQpOzxicj4NCsKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKg
IMKgIMKgIMKgIMKgIMKgIMKgIMKgIGUgPSB2Yi0mZ3Q7dmEtJmd0O3ZhX3N0YXJ0ICsgKGogJmx0
OyZsdDsgUEFHRV9TSElGVCk7PGJyPg0KQEAgLTEwMzQsMTAgKzEwMzUsNiBAQCB2b2lkIHZtX3Vu
bWFwX2FsaWFzZXModm9pZCk8YnI+DQrCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCBzdGFydCA9IHM7PGJyPg0KwqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgaWYgKGUgJmd0OyBlbmQpPGJyPg0KwqAg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
ZW5kID0gZTs8YnI+DQotPGJyPg0KLSDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCBpID0gajs8YnI+DQotIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKg
IMKgIMKgIMKgIMKgIGkgPSBmaW5kX25leHRfYml0KHZiLSZndDtkaXJ0eV9tYXAsPGJyPg0KLSDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCBWTUFQX0JCTUFQX0JJVFMsIGkpOzxicj4NCsKgIMKgIMKg
IMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIH08YnI+DQrCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCBzcGluX3VubG9jaygmYW1wO3ZiLSZndDtsb2NrKTs8YnI+DQrCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCB9PGJyPg0KLS08YnI+DQoxLjcuOS41PGJyPg0KPGJyPg0KLS08YnI+
DQpUbyB1bnN1YnNjcmliZSBmcm9tIHRoaXMgbGlzdDogc2VuZCB0aGUgbGluZSAmcXVvdDt1bnN1
YnNjcmliZSBsaW51eC1rZXJuZWwmcXVvdDsgaW48YnI+DQp0aGUgYm9keSBvZiBhIG1lc3NhZ2Ug
dG8gPGEgaHJlZj0iamF2YXNjcmlwdDo7IiBvbmNsaWNrPSJfZShldmVudCwgJiMzOTtjdm1sJiMz
OTssICYjMzk7bWFqb3Jkb21vQHZnZXIua2VybmVsLm9yZyYjMzk7KSI+bWFqb3Jkb21vQHZnZXIu
a2VybmVsLm9yZzwvYT48YnI+DQpNb3JlIG1ham9yZG9tbyBpbmZvIGF0IMKgPGEgaHJlZj0iaHR0
cDovL3ZnZXIua2VybmVsLm9yZy9tYWpvcmRvbW8taW5mby5odG1sIiB0YXJnZXQ9Il9ibGFuayI+
aHR0cDovL3ZnZXIua2VybmVsLm9yZy9tYWpvcmRvbW8taW5mby5odG1sPC9hPjxicj4NClBsZWFz
ZSByZWFkIHRoZSBGQVEgYXQgwqA8YSBocmVmPSJodHRwOi8vd3d3LnR1eC5vcmcvbGttbC8iIHRh
cmdldD0iX2JsYW5rIj5odHRwOi8vd3d3LnR1eC5vcmcvbGttbC88L2E+PGJyPg0KPC9ibG9ja3F1
b3RlPg0K
--047d7b10cce91f3cd704e30067db--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
