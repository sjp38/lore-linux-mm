Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9BD716B007B
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 16:31:10 -0400 (EDT)
Received: by gwj16 with SMTP id 16so3582928gwj.14
        for <linux-mm@kvack.org>; Tue, 31 Aug 2010 13:31:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1008301114460.10316@router.home>
References: <1281374816-904-1-git-send-email-ngupta@vflare.org>
	<1281374816-904-4-git-send-email-ngupta@vflare.org>
	<alpine.DEB.2.00.1008301114460.10316@router.home>
Date: Tue, 31 Aug 2010 16:31:08 -0400
Message-ID: <AANLkTikdhnr12uU8Wp60BygZwH770RBfxyfLNMzUsQje@mail.gmail.com>
Subject: Re: [PATCH 03/10] Use percpu stats
From: Nitin Gupta <ngupta@vflare.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Linux Driver Project <devel@driverdev.osuosl.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 30, 2010 at 12:20 PM, Christoph Lameter <cl@linux.com> wrote:
> On Mon, 9 Aug 2010, Nitin Gupta wrote:
>
>> -static void zram_stat_inc(u32 *v)
>> +static void zram_add_stat(struct zram *zram,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum zram_stats_index idx, s64=
 val)
>> =A0{
>> - =A0 =A0 *v =3D *v + 1;
>> + =A0 =A0 struct zram_stats_cpu *stats;
>> +
>> + =A0 =A0 preempt_disable();
>> + =A0 =A0 stats =3D __this_cpu_ptr(zram->stats);
>> + =A0 =A0 u64_stats_update_begin(&stats->syncp);
>> + =A0 =A0 stats->count[idx] +=3D val;
>> + =A0 =A0 u64_stats_update_end(&stats->syncp);
>> + =A0 =A0 preempt_enable();
>
> Maybe do
>
> #define zram_add_stat(zram, index, val)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0this_cpu_add(zram->stats->count[index], va=
l)
>
> instead? It creates an add in a single "atomic" per cpu instruction and
> deals with the fallback scenarios for processors that cannot handle 64
> bit adds.
>
>

Yes, this_cpu_add() seems sufficient. I can't recall why I used u64_stats_*
but if it's not required for atomic access to 64-bit then why was it added =
to
the mainline in the first place?

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
