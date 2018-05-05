Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5539B6B0010
	for <linux-mm@kvack.org>; Sat,  5 May 2018 19:05:07 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id w18-v6so23879688ioe.3
        for <linux-mm@kvack.org>; Sat, 05 May 2018 16:05:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n5-v6sor2538562ite.88.2018.05.05.16.05.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 05 May 2018 16:05:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <dc56acf384130d9703684a239d8daa8748f63d8e.1525536580.git.mchehab+samsung@kernel.org>
References: <dc56acf384130d9703684a239d8daa8748f63d8e.1525536580.git.mchehab+samsung@kernel.org>
From: Tomoki Sekiyama <tomoki.sekiyama@gmail.com>
Date: Sun, 6 May 2018 08:05:05 +0900
Message-ID: <CAM1upfOiM77w=_65xarL9=68cTDP81b3_cx02v8mUjsrCwBo=Q@mail.gmail.com>
Subject: Re: [PATCH 1/2] media: siano: don't use GFP_DMA
Content-Type: multipart/alternative; boundary="0000000000009f5672056b7d7794"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
Cc: Linux Media Mailing List <linux-media@vger.kernel.org>, Mauro Carvalho Chehab <mchehab@infradead.org>, Markus Elfring <elfring@users.sourceforge.net>, Hans Verkuil <hansverk@cisco.com>, "Luis R. Rodriguez" <mcgrof@kernel.org>, linux-mm@kvack.org

--0000000000009f5672056b7d7794
Content-Type: text/plain; charset="UTF-8"

2018/5/6 1:09 Mauro Carvalho Chehab <mchehab+samsung@kernel.org>:

> I can't think on a single reason why this driver would be using
> GFP_DMA. The typical usage is as an USB driver. Any DMA restrictions
> should be handled inside the HCI driver, if any.
>

siano driver supports SDIO (implemented
in drivers/media/mmc/siano/smssdio.c) as well as USB.
It looks like using sdio_memcpy_toio() to DMA transfer. I think that's why
it is using GFP_DMA.


> Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>
> Cc: linux-mm@kvack.org
> Signed-off-by: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
> ---
>  drivers/media/common/siano/smscoreapi.c | 20 ++++++++++----------
>  1 file changed, 10 insertions(+), 10 deletions(-)
>
> diff --git a/drivers/media/common/siano/smscoreapi.c
> b/drivers/media/common/siano/smscoreapi.c
> index 1c93258a2d47..a5f0db0810d4 100644
> --- a/drivers/media/common/siano/smscoreapi.c
> +++ b/drivers/media/common/siano/smscoreapi.c
> @@ -697,7 +697,7 @@ int smscore_register_device(struct smsdevice_params_t
> *params,
>                 buffer = dma_alloc_coherent(params->device,
>                                             dev->common_buffer_size,
>                                             &dev->common_buffer_phys,
> -                                           GFP_KERNEL | GFP_DMA);
> +                                           GFP_KERNEL);
>         if (!buffer) {
>                 smscore_unregister_device(dev);
>                 return -ENOMEM;
> @@ -792,7 +792,7 @@ static int smscore_init_ir(struct smscore_device_t
> *coredev)
>                 else {
>                         buffer = kmalloc(sizeof(struct sms_msg_data2) +
>                                                 SMS_DMA_ALIGNMENT,
> -                                               GFP_KERNEL | GFP_DMA);
> +                                               GFP_KERNEL);
>                         if (buffer) {
>                                 struct sms_msg_data2 *msg =
>                                 (struct sms_msg_data2 *)
> @@ -933,7 +933,7 @@ static int smscore_load_firmware_family2(struct
> smscore_device_t *coredev,
>         }
>
>         /* PAGE_SIZE buffer shall be enough and dma aligned */
> -       msg = kmalloc(PAGE_SIZE, GFP_KERNEL | GFP_DMA);
> +       msg = kmalloc(PAGE_SIZE, GFP_KERNEL);
>         if (!msg)
>                 return -ENOMEM;
>
> @@ -1168,7 +1168,7 @@ static int smscore_load_firmware_from_file(struct
> smscore_device_t *coredev,
>         }
>         pr_debug("read fw %s, buffer size=0x%zx\n", fw_filename, fw->size);
>         fw_buf = kmalloc(ALIGN(fw->size + sizeof(struct sms_firmware),
> -                        SMS_ALLOC_ALIGNMENT), GFP_KERNEL | GFP_DMA);
> +                        SMS_ALLOC_ALIGNMENT), GFP_KERNEL);
>         if (!fw_buf) {
>                 pr_err("failed to allocate firmware buffer\n");
>                 rc = -ENOMEM;
> @@ -1260,7 +1260,7 @@ EXPORT_SYMBOL_GPL(smscore_unregister_device);
>  static int smscore_detect_mode(struct smscore_device_t *coredev)
>  {
>         void *buffer = kmalloc(sizeof(struct sms_msg_hdr) +
> SMS_DMA_ALIGNMENT,
> -                              GFP_KERNEL | GFP_DMA);
> +                              GFP_KERNEL);
>         struct sms_msg_hdr *msg =
>                 (struct sms_msg_hdr *) SMS_ALIGN_ADDRESS(buffer);
>         int rc;
> @@ -1309,7 +1309,7 @@ static int smscore_init_device(struct
> smscore_device_t *coredev, int mode)
>         int rc = 0;
>
>         buffer = kmalloc(sizeof(struct sms_msg_data) +
> -                       SMS_DMA_ALIGNMENT, GFP_KERNEL | GFP_DMA);
> +                       SMS_DMA_ALIGNMENT, GFP_KERNEL);
>         if (!buffer)
>                 return -ENOMEM;
>
> @@ -1398,7 +1398,7 @@ int smscore_set_device_mode(struct smscore_device_t
> *coredev, int mode)
>                 coredev->device_flags &= ~SMS_DEVICE_NOT_READY;
>
>                 buffer = kmalloc(sizeof(struct sms_msg_data) +
> -                                SMS_DMA_ALIGNMENT, GFP_KERNEL | GFP_DMA);
> +                                SMS_DMA_ALIGNMENT, GFP_KERNEL);
>                 if (buffer) {
>                         struct sms_msg_data *msg = (struct sms_msg_data *)
> SMS_ALIGN_ADDRESS(buffer);
>
> @@ -1971,7 +1971,7 @@ int smscore_gpio_configure(struct smscore_device_t
> *coredev, u8 pin_num,
>         total_len = sizeof(struct sms_msg_hdr) + (sizeof(u32) * 6);
>
>         buffer = kmalloc(total_len + SMS_DMA_ALIGNMENT,
> -                       GFP_KERNEL | GFP_DMA);
> +                       GFP_KERNEL);
>         if (!buffer)
>                 return -ENOMEM;
>
> @@ -2043,7 +2043,7 @@ int smscore_gpio_set_level(struct smscore_device_t
> *coredev, u8 pin_num,
>                         (3 * sizeof(u32)); /* keep it 3 ! */
>
>         buffer = kmalloc(total_len + SMS_DMA_ALIGNMENT,
> -                       GFP_KERNEL | GFP_DMA);
> +                       GFP_KERNEL);
>         if (!buffer)
>                 return -ENOMEM;
>
> @@ -2091,7 +2091,7 @@ int smscore_gpio_get_level(struct smscore_device_t
> *coredev, u8 pin_num,
>         total_len = sizeof(struct sms_msg_hdr) + (2 * sizeof(u32));
>
>         buffer = kmalloc(total_len + SMS_DMA_ALIGNMENT,
> -                       GFP_KERNEL | GFP_DMA);
> +                       GFP_KERNEL);
>         if (!buffer)
>                 return -ENOMEM;
>
> --
> 2.17.0
>
>

--0000000000009f5672056b7d7794
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: base64

PGRpdiBkaXI9Imx0ciI+MjAxOC81LzYgMTowOSBNYXVybyBDYXJ2YWxobyBDaGVoYWIgJmx0Ozxh
IGhyZWY9Im1haWx0bzptY2hlaGFiJTJCc2Ftc3VuZ0BrZXJuZWwub3JnIiB0YXJnZXQ9Il9ibGFu
ayI+bWNoZWhhYitzYW1zdW5nQGtlcm5lbC5vcmc8L2E+Jmd0Ozo8YnI+PGRpdiBjbGFzcz0iZ21h
aWxfcXVvdGUiPjxibG9ja3F1b3RlIGNsYXNzPSJnbWFpbF9xdW90ZSIgc3R5bGU9Im1hcmdpbjow
cHggMHB4IDBweCAwLjhleDtib3JkZXItbGVmdC13aWR0aDoxcHg7Ym9yZGVyLWxlZnQtc3R5bGU6
c29saWQ7Ym9yZGVyLWxlZnQtY29sb3I6cmdiKDIwNCwyMDQsMjA0KTtwYWRkaW5nLWxlZnQ6MWV4
Ij5JIGNhbiYjMzk7dCB0aGluayBvbiBhIHNpbmdsZSByZWFzb24gd2h5IHRoaXMgZHJpdmVyIHdv
dWxkIGJlIHVzaW5nPGJyPg0KR0ZQX0RNQS4gVGhlIHR5cGljYWwgdXNhZ2UgaXMgYXMgYW4gVVNC
IGRyaXZlci4gQW55IERNQSByZXN0cmljdGlvbnM8YnI+DQpzaG91bGQgYmUgaGFuZGxlZCBpbnNp
ZGUgdGhlIEhDSSBkcml2ZXIsIGlmIGFueS48YnI+PC9ibG9ja3F1b3RlPjxkaXY+PGJyPjwvZGl2
PjxkaXY+c2lhbm8gZHJpdmVyIHN1cHBvcnRzIFNESU8gKGltcGxlbWVudGVkIGluwqBkcml2ZXJz
L21lZGlhL21tYy9zaWFuby9zbXNzZGlvLmMpIGFzIHdlbGwgYXMgVVNCLjwvZGl2PjxkaXY+SXQg
bG9va3MgbGlrZSB1c2luZ8Kgc2Rpb19tZW1jcHlfdG9pbygpIHRvIERNQSB0cmFuc2Zlci4gSSB0
aGluayB0aGF0JiMzOTtzIHdoeSBpdCBpcyB1c2luZyBHRlBfRE1BLjwvZGl2PjxkaXY+wqA8L2Rp
dj48YmxvY2txdW90ZSBjbGFzcz0iZ21haWxfcXVvdGUiIHN0eWxlPSJtYXJnaW46MHB4IDBweCAw
cHggMC44ZXg7Ym9yZGVyLWxlZnQtd2lkdGg6MXB4O2JvcmRlci1sZWZ0LXN0eWxlOnNvbGlkO2Jv
cmRlci1sZWZ0LWNvbG9yOnJnYigyMDQsMjA0LDIwNCk7cGFkZGluZy1sZWZ0OjFleCI+DQpDYzog
JnF1b3Q7THVpcyBSLiBSb2RyaWd1ZXomcXVvdDsgJmx0OzxhIGhyZWY9Im1haWx0bzptY2dyb2ZA
a2VybmVsLm9yZyIgdGFyZ2V0PSJfYmxhbmsiPm1jZ3JvZkBrZXJuZWwub3JnPC9hPiZndDs8YnI+
DQpDYzogPGEgaHJlZj0ibWFpbHRvOmxpbnV4LW1tQGt2YWNrLm9yZyIgdGFyZ2V0PSJfYmxhbmsi
PmxpbnV4LW1tQGt2YWNrLm9yZzwvYT48YnI+DQpTaWduZWQtb2ZmLWJ5OiBNYXVybyBDYXJ2YWxo
byBDaGVoYWIgJmx0OzxhIGhyZWY9Im1haWx0bzptY2hlaGFiJTJCc2Ftc3VuZ0BrZXJuZWwub3Jn
IiB0YXJnZXQ9Il9ibGFuayI+bWNoZWhhYitzYW1zdW5nQGtlcm5lbC5vcmc8L2E+Jmd0Ozxicj4N
Ci0tLTxicj4NCsKgZHJpdmVycy9tZWRpYS9jb21tb24vc2lhbm8vPHdicj5zbXNjb3JlYXBpLmMg
fCAyMCArKysrKysrKysrLS0tLS0tLS0tLTxicj4NCsKgMSBmaWxlIGNoYW5nZWQsIDEwIGluc2Vy
dGlvbnMoKyksIDEwIGRlbGV0aW9ucygtKTxicj4NCjxicj4NCmRpZmYgLS1naXQgYS9kcml2ZXJz
L21lZGlhL2NvbW1vbi9zaWFuby88d2JyPnNtc2NvcmVhcGkuYyBiL2RyaXZlcnMvbWVkaWEvY29t
bW9uL3NpYW5vLzx3YnI+c21zY29yZWFwaS5jPGJyPg0KaW5kZXggMWM5MzI1OGEyZDQ3Li5hNWYw
ZGIwODEwZDQgMTAwNjQ0PGJyPg0KLS0tIGEvZHJpdmVycy9tZWRpYS9jb21tb24vc2lhbm8vPHdi
cj5zbXNjb3JlYXBpLmM8YnI+DQorKysgYi9kcml2ZXJzL21lZGlhL2NvbW1vbi9zaWFuby88d2Jy
PnNtc2NvcmVhcGkuYzxicj4NCkBAIC02OTcsNyArNjk3LDcgQEAgaW50IHNtc2NvcmVfcmVnaXN0
ZXJfZGV2aWNlKHN0cnVjdCBzbXNkZXZpY2VfcGFyYW1zX3QgKnBhcmFtcyw8YnI+DQrCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCBidWZmZXIgPSBkbWFfYWxsb2NfY29oZXJlbnQocGFyYW1zLSZndDs8
d2JyPmRldmljZSw8YnI+DQrCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCBkZXYtJmd0O2NvbW1vbl9idWZmZXJfc2l6ZSw8YnI+
DQrCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCAmYW1wO2Rldi0mZ3Q7Y29tbW9uX2J1ZmZlcl9waHlzLDxicj4NCi3CoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oEdGUF9LRVJORUwgfCBHRlBfRE1BKTs8YnI+DQorwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqBHRlBfS0VSTkVMKTs8YnI+DQrC
oCDCoCDCoCDCoCBpZiAoIWJ1ZmZlcikgezxicj4NCsKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIHNt
c2NvcmVfdW5yZWdpc3Rlcl9kZXZpY2UoZGV2KTx3YnI+Ozxicj4NCsKgIMKgIMKgIMKgIMKgIMKg
IMKgIMKgIHJldHVybiAtRU5PTUVNOzxicj4NCkBAIC03OTIsNyArNzkyLDcgQEAgc3RhdGljIGlu
dCBzbXNjb3JlX2luaXRfaXIoc3RydWN0IHNtc2NvcmVfZGV2aWNlX3QgKmNvcmVkZXYpPGJyPg0K
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgZWxzZSB7PGJyPg0KwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqAgYnVmZmVyID0ga21hbGxvYyhzaXplb2Yoc3RydWN0IHNtc19tc2dfZGF0
YTIpICs8YnI+DQrCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCBTTVNfRE1BX0FMSUdOTUVOVCw8YnI+DQotwqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqBHRlBfS0VSTkVMIHwgR0ZQX0RNQSk7PGJyPg0KK8KgIMKgIMKgIMKgIMKgIMKgIMKg
IMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgR0ZQX0tF
Uk5FTCk7PGJyPg0KwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgaWYgKGJ1ZmZl
cikgezxicj4NCsKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKg
IHN0cnVjdCBzbXNfbXNnX2RhdGEyICptc2cgPTxicj4NCsKgIMKgIMKgIMKgIMKgIMKgIMKgIMKg
IMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIChzdHJ1Y3Qgc21zX21zZ19kYXRhMiAqKTxicj4NCkBA
IC05MzMsNyArOTMzLDcgQEAgc3RhdGljIGludCBzbXNjb3JlX2xvYWRfZmlybXdhcmVfZmFtaWx5
Mig8d2JyPnN0cnVjdCBzbXNjb3JlX2RldmljZV90ICpjb3JlZGV2LDxicj4NCsKgIMKgIMKgIMKg
IH08YnI+DQo8YnI+DQrCoCDCoCDCoCDCoCAvKiBQQUdFX1NJWkUgYnVmZmVyIHNoYWxsIGJlIGVu
b3VnaCBhbmQgZG1hIGFsaWduZWQgKi88YnI+DQotwqAgwqAgwqAgwqBtc2cgPSBrbWFsbG9jKFBB
R0VfU0laRSwgR0ZQX0tFUk5FTCB8IEdGUF9ETUEpOzxicj4NCivCoCDCoCDCoCDCoG1zZyA9IGtt
YWxsb2MoUEFHRV9TSVpFLCBHRlBfS0VSTkVMKTs8YnI+DQrCoCDCoCDCoCDCoCBpZiAoIW1zZyk8
YnI+DQrCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCByZXR1cm4gLUVOT01FTTs8YnI+DQo8YnI+DQpA
QCAtMTE2OCw3ICsxMTY4LDcgQEAgc3RhdGljIGludCBzbXNjb3JlX2xvYWRfZmlybXdhcmVfZnJv
bV88d2JyPmZpbGUoc3RydWN0IHNtc2NvcmVfZGV2aWNlX3QgKmNvcmVkZXYsPGJyPg0KwqAgwqAg
wqAgwqAgfTxicj4NCsKgIMKgIMKgIMKgIHByX2RlYnVnKCZxdW90O3JlYWQgZncgJXMsIGJ1ZmZl
ciBzaXplPTB4JXp4XG4mcXVvdDssIGZ3X2ZpbGVuYW1lLCBmdy0mZ3Q7c2l6ZSk7PGJyPg0KwqAg
wqAgwqAgwqAgZndfYnVmID0ga21hbGxvYyhBTElHTihmdy0mZ3Q7c2l6ZSArIHNpemVvZihzdHJ1
Y3Qgc21zX2Zpcm13YXJlKSw8YnI+DQotwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgU01TX0FMTE9DX0FMSUdOTUVOVCksIEdGUF9LRVJORUwgfCBHRlBfRE1BKTs8YnI+DQorwqAg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgU01TX0FMTE9DX0FMSUdOTUVOVCksIEdG
UF9LRVJORUwpOzxicj4NCsKgIMKgIMKgIMKgIGlmICghZndfYnVmKSB7PGJyPg0KwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqAgcHJfZXJyKCZxdW90O2ZhaWxlZCB0byBhbGxvY2F0ZSBmaXJtd2FyZSBi
dWZmZXJcbiZxdW90Oyk7PGJyPg0KwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgcmMgPSAtRU5PTUVN
Ozxicj4NCkBAIC0xMjYwLDcgKzEyNjAsNyBAQCBFWFBPUlRfU1lNQk9MX0dQTChzbXNjb3JlXzx3
YnI+dW5yZWdpc3Rlcl9kZXZpY2UpOzxicj4NCsKgc3RhdGljIGludCBzbXNjb3JlX2RldGVjdF9t
b2RlKHN0cnVjdCBzbXNjb3JlX2RldmljZV90ICpjb3JlZGV2KTxicj4NCsKgezxicj4NCsKgIMKg
IMKgIMKgIHZvaWQgKmJ1ZmZlciA9IGttYWxsb2Moc2l6ZW9mKHN0cnVjdCBzbXNfbXNnX2hkcikg
KyBTTVNfRE1BX0FMSUdOTUVOVCw8YnI+DQotwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqAgR0ZQX0tFUk5FTCB8IEdGUF9ETUEpOzxicj4NCivCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCBHRlBfS0VSTkVMKTs8YnI+DQrCoCDCoCDC
oCDCoCBzdHJ1Y3Qgc21zX21zZ19oZHIgKm1zZyA9PGJyPg0KwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgKHN0cnVjdCBzbXNfbXNnX2hkciAqKSBTTVNfQUxJR05fQUREUkVTUyhidWZmZXIpOzxicj4N
CsKgIMKgIMKgIMKgIGludCByYzs8YnI+DQpAQCAtMTMwOSw3ICsxMzA5LDcgQEAgc3RhdGljIGlu
dCBzbXNjb3JlX2luaXRfZGV2aWNlKHN0cnVjdCBzbXNjb3JlX2RldmljZV90ICpjb3JlZGV2LCBp
bnQgbW9kZSk8YnI+DQrCoCDCoCDCoCDCoCBpbnQgcmMgPSAwOzxicj4NCjxicj4NCsKgIMKgIMKg
IMKgIGJ1ZmZlciA9IGttYWxsb2Moc2l6ZW9mKHN0cnVjdCBzbXNfbXNnX2RhdGEpICs8YnI+DQot
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqBTTVNfRE1BX0FMSUdOTUVOVCwgR0ZQ
X0tFUk5FTCB8IEdGUF9ETUEpOzxicj4NCivCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoFNNU19ETUFfQUxJR05NRU5ULCBHRlBfS0VSTkVMKTs8YnI+DQrCoCDCoCDCoCDCoCBpZiAo
IWJ1ZmZlcik8YnI+DQrCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCByZXR1cm4gLUVOT01FTTs8YnI+
DQo8YnI+DQpAQCAtMTM5OCw3ICsxMzk4LDcgQEAgaW50IHNtc2NvcmVfc2V0X2RldmljZV9tb2Rl
KHN0cnVjdCBzbXNjb3JlX2RldmljZV90ICpjb3JlZGV2LCBpbnQgbW9kZSk8YnI+DQrCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCBjb3JlZGV2LSZndDtkZXZpY2VfZmxhZ3MgJmFtcDs9IH5TTVNfREVW
SUNFX05PVF9SRUFEWTs8YnI+DQo8YnI+DQrCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCBidWZmZXIg
PSBrbWFsbG9jKHNpemVvZihzdHJ1Y3Qgc21zX21zZ19kYXRhKSArPGJyPg0KLcKgIMKgIMKgIMKg
IMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIFNNU19ETUFfQUxJR05NRU5ULCBH
RlBfS0VSTkVMIHwgR0ZQX0RNQSk7PGJyPg0KK8KgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKg
IMKgIMKgIMKgIMKgIMKgIMKgIFNNU19ETUFfQUxJR05NRU5ULCBHRlBfS0VSTkVMKTs8YnI+DQrC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCBpZiAoYnVmZmVyKSB7PGJyPg0KwqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgc3RydWN0IHNtc19tc2dfZGF0YSAqbXNnID0gKHN0cnVjdCBz
bXNfbXNnX2RhdGEgKikgU01TX0FMSUdOX0FERFJFU1MoYnVmZmVyKTs8YnI+DQo8YnI+DQpAQCAt
MTk3MSw3ICsxOTcxLDcgQEAgaW50IHNtc2NvcmVfZ3Bpb19jb25maWd1cmUoc3RydWN0IHNtc2Nv
cmVfZGV2aWNlX3QgKmNvcmVkZXYsIHU4IHBpbl9udW0sPGJyPg0KwqAgwqAgwqAgwqAgdG90YWxf
bGVuID0gc2l6ZW9mKHN0cnVjdCBzbXNfbXNnX2hkcikgKyAoc2l6ZW9mKHUzMikgKiA2KTs8YnI+
DQo8YnI+DQrCoCDCoCDCoCDCoCBidWZmZXIgPSBrbWFsbG9jKHRvdGFsX2xlbiArIFNNU19ETUFf
QUxJR05NRU5ULDxicj4NCi3CoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoEdGUF9L
RVJORUwgfCBHRlBfRE1BKTs8YnI+DQorwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqBHRlBfS0VSTkVMKTs8YnI+DQrCoCDCoCDCoCDCoCBpZiAoIWJ1ZmZlcik8YnI+DQrCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCByZXR1cm4gLUVOT01FTTs8YnI+DQo8YnI+DQpAQCAtMjA0Myw3ICsy
MDQzLDcgQEAgaW50IHNtc2NvcmVfZ3Bpb19zZXRfbGV2ZWwoc3RydWN0IHNtc2NvcmVfZGV2aWNl
X3QgKmNvcmVkZXYsIHU4IHBpbl9udW0sPGJyPg0KwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqAgKDMgKiBzaXplb2YodTMyKSk7IC8qIGtlZXAgaXQgMyAhICovPGJyPg0KPGJyPg0K
wqAgwqAgwqAgwqAgYnVmZmVyID0ga21hbGxvYyh0b3RhbF9sZW4gKyBTTVNfRE1BX0FMSUdOTUVO
VCw8YnI+DQotwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqBHRlBfS0VSTkVMIHwg
R0ZQX0RNQSk7PGJyPg0KK8KgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgR0ZQX0tF
Uk5FTCk7PGJyPg0KwqAgwqAgwqAgwqAgaWYgKCFidWZmZXIpPGJyPg0KwqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqAgcmV0dXJuIC1FTk9NRU07PGJyPg0KPGJyPg0KQEAgLTIwOTEsNyArMjA5MSw3IEBA
IGludCBzbXNjb3JlX2dwaW9fZ2V0X2xldmVsKHN0cnVjdCBzbXNjb3JlX2RldmljZV90ICpjb3Jl
ZGV2LCB1OCBwaW5fbnVtLDxicj4NCsKgIMKgIMKgIMKgIHRvdGFsX2xlbiA9IHNpemVvZihzdHJ1
Y3Qgc21zX21zZ19oZHIpICsgKDIgKiBzaXplb2YodTMyKSk7PGJyPg0KPGJyPg0KwqAgwqAgwqAg
wqAgYnVmZmVyID0ga21hbGxvYyh0b3RhbF9sZW4gKyBTTVNfRE1BX0FMSUdOTUVOVCw8YnI+DQot
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqBHRlBfS0VSTkVMIHwgR0ZQX0RNQSk7
PGJyPg0KK8KgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgR0ZQX0tFUk5FTCk7PGJy
Pg0KwqAgwqAgwqAgwqAgaWYgKCFidWZmZXIpPGJyPg0KwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
cmV0dXJuIC1FTk9NRU07PGJyPg0KPGJyPg0KLS0gPGJyPg0KMi4xNy4wPGJyPg0KPGJyPg0KPC9i
bG9ja3F1b3RlPjwvZGl2PjwvZGl2Pg0K
--0000000000009f5672056b7d7794--
