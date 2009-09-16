Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 8A9C76B004F
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 03:21:59 -0400 (EDT)
Received: by ywh9 with SMTP id 9so6724324ywh.32
        for <linux-mm@kvack.org>; Wed, 16 Sep 2009 00:22:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LNX.2.00.0909151202560.17028@wotan.suse.de>
References: <20090915085441.GF23126@kernel.dk>
	 <alpine.LNX.2.00.0909151202560.17028@wotan.suse.de>
Date: Wed, 16 Sep 2009 16:16:46 +0900
Message-ID: <28c262360909160016m19edee02g9215669f854e1026@mail.gmail.com>
Subject: Re: BUG: sleeping function called from invalid context at
	mm/slub.c:1717
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Jiri Kosina <jkosina@suse.cz>
Cc: Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi, Jiri.

On Tue, Sep 15, 2009 at 7:10 PM, Jiri Kosina <jkosina@suse.cz> wrote:
> On Tue, 15 Sep 2009, Jens Axboe wrote:
>
>> This is new with todays -git:
>>
>> BUG: sleeping function called from invalid context at mm/slub.c:1717
>> in_atomic(): 1, irqs_disabled(): 1, pid: 0, name: swapper
>> Pid: 0, comm: swapper Not tainted 2.6.31 #206
>> Call Trace:
>> =A0<IRQ> =A0[<ffffffff8103eb23>] __might_sleep+0xf3/0x110
>> =A0[<ffffffff810e4d83>] kmem_cache_alloc+0x123/0x170
>> =A0[<ffffffff813306c9>] hid_input_report+0x89/0x3a0
>> =A0[<ffffffffa00cd5f4>] hid_ctrl+0xa4/0x1f0 [usbhid]
>> =A0[<ffffffff8108a4c7>] ? handle_IRQ_event+0xa7/0x1e0
>> =A0[<ffffffffa004da1f>] usb_hcd_giveback_urb+0x3f/0xa0 [usbcore]
>> =A0[<ffffffffa0074ab4>] uhci_giveback_urb+0xb4/0x240 [uhci_hcd]
>> =A0[<ffffffffa00750e7>] uhci_scan_schedule+0x357/0xab0 [uhci_hcd]
>> =A0[<ffffffffa0077a01>] uhci_irq+0x91/0x190 [uhci_hcd]
>> =A0[<ffffffffa004d44e>] usb_hcd_irq+0x2e/0x70 [usbcore]
>> =A0[<ffffffff8108a4c7>] handle_IRQ_event+0xa7/0x1e0
>> =A0[<ffffffff8108c58c>] handle_fasteoi_irq+0x7c/0xf0
>> =A0[<ffffffff8100f176>] handle_irq+0x46/0xa0
>> =A0[<ffffffff8100e49a>] do_IRQ+0x6a/0xf0
>> =A0[<ffffffff8100c853>] ret_from_intr+0x0/0xa
>>
>> And I notice there's a HID merge from yesterday, Jiri CC'ed.
>
> Thanks for letting me know. The patch below should fix it.
>
>
>
> From: Jiri Kosina <jkosina@suse.cz>
> Subject: [PATCH] HID: fix non-atomic allocation in hid_input_report
>
> 'interrupt' variable can't be used to safely determine whether
> we are running in atomic context or not, as we might be called from
> during control transfer completion through hid_ctrl() in atomic
> context with interrupt =3D=3D 0.

I am not a USB expert so It might be dump comment. :)

We have to change description of hid_input_report.

 * @interrupt: called from atomic?

I think it lost meaning.
I am worried that interrupt variable is propagated down
to sub functions. Is it right on sub functions?

One more thing, I am concerned about increasing
GFP_ATOMIC customers although we can avoid it.
Is it called rarely?
Could you find a alternative method to overcome this issue?


>
> Reported-by: Jens Axboe <jens.axboe@oracle.com>
> Signed-off-by: Jiri Kosina <jkosina@suse.cz>
> ---
> =A0drivers/hid/hid-core.c | =A0 =A03 +--
> =A01 files changed, 1 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/hid/hid-core.c b/drivers/hid/hid-core.c
> index 342b7d3..ca9bb26 100644
> --- a/drivers/hid/hid-core.c
> +++ b/drivers/hid/hid-core.c
> @@ -1089,8 +1089,7 @@ int hid_input_report(struct hid_device *hid, int ty=
pe, u8 *data, int size, int i
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -1;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 buf =3D kmalloc(sizeof(char) * HID_DEBUG_BUFSIZE,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 interrupt ? GFP_ATOMIC : GF=
P_KERNEL);
> + =A0 =A0 =A0 buf =3D kmalloc(sizeof(char) * HID_DEBUG_BUFSIZE, GFP_ATOMI=
C);
>
> =A0 =A0 =A0 =A0if (!buf) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0report =3D hid_get_report(report_enum, dat=
a);
> --
> 1.5.6
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
