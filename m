Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 504EE900225
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 05:38:07 -0400 (EDT)
Received: by qyk32 with SMTP id 32so242548qyk.14
        for <linux-mm@kvack.org>; Fri, 24 Jun 2011 02:38:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTikKwbsRD=WszbaUQQMamQbNXFdsPA@mail.gmail.com>
References: <BANLkTik7ubq9ChR6UEBXOo5D9tn3mMb1Yw@mail.gmail.com>
	<BANLkTikKwbsRD=WszbaUQQMamQbNXFdsPA@mail.gmail.com>
Date: Fri, 24 Jun 2011 18:38:05 +0900
Message-ID: <BANLkTi=ODjQC+czO+9iQS-CcnNxo_uNkUg@mail.gmail.com>
Subject: Re: Root-causing kswapd spinning on Sandy Bridge laptops?
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Lutomirski <luto@mit.edu>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, =?UTF-8?Q?P=C3=A1draig_Brady?= <P@draigbrady.com>

On Fri, Jun 24, 2011 at 6:27 PM, Minchan Kim <minchan.kim@gmail.com> wrote:
> Hi Andrew,
>
> Sorry but right now I don't have a time to dive into this.
> But it seems to be similar to the problem Mel is looking at.
> Cced him.
>
> Even, P=C3=A1draig Brady seem to have a reproducible scenario.
> I will look when I have a time.
> I hope I will be back sooner or later.
>
>
> On Fri, Jun 24, 2011 at 3:22 PM, Andrew Lutomirski <luto@mit.edu> wrote:
>> I'm back :-/
>>
>> I just triggered the kswapd bug on 2.6.39.1, which has the
>> cond_resched in shrink_slab. =C2=A0This time my system's still usable (I=
'm
>> tying this email on it), but kswapd0 is taking 100% cpu. =C2=A0It *does*
>> schedule (tested by setting its affinity the same as another CPU hog
>> and confirming that each one gets 50%).
>>
>> It appears to be calling i915_gem_inactive_shrink in a loop. =C2=A0I hav=
e
>> probes on entry and return of i915_gem_inactive_shrink and on return
>> of shrink_slab. =C2=A0I see:
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 kswapd0 =C2=A0 =C2=A047 [000] 59599.956573: =
mm_vmscan_kswapd_wake: nid=3D0 order=3D0
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 kswapd0 =C2=A0 =C2=A047 [000] 59599.956575: =
shrink_zone:
>> (ffffffff810c848c) priority=3D12 zone=3Dffff8801005fe000
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 kswapd0 =C2=A0 =C2=A047 [000] 59599.956576: =
shrink_zone_return:
>> (ffffffff810c848c <- ffffffff810c96c6) arg1=3D0
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 kswapd0 =C2=A0 =C2=A047 [000] 59599.956578: =
i915_gem_inactive_shrink:
>> (ffffffffa0081e48) gfp_mask=3Dd0 nr_to_scan=3D0
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 kswapd0 =C2=A0 =C2=A047 [000] 59599.956589: =
shrink_return:
>> (ffffffffa0081e48 <- ffffffff810c6a62) arg1=3D320
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 kswapd0 =C2=A0 =C2=A047 [000] 59599.956589: =
shrink_slab_return:
>> (ffffffff810c69f5 <- ffffffff810c96ec) arg1=3D0
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 kswapd0 =C2=A0 =C2=A047 [000] 59599.956592: =
i915_gem_inactive_shrink:
>> (ffffffffa0081e48) gfp_mask=3Dd0 nr_to_scan=3D0
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 kswapd0 =C2=A0 =C2=A047 [000] 59599.956602: =
shrink_return:
>> (ffffffffa0081e48 <- ffffffff810c6a62) arg1=3D320
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 kswapd0 =C2=A0 =C2=A047 [000] 59599.956603: =
shrink_slab_return:
>> (ffffffff810c69f5 <- ffffffff810c96ec) arg1=3D0
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 kswapd0 =C2=A0 =C2=A047 [000] 59599.956605: =
shrink_zone:
>> (ffffffff810c848c) priority=3D12 zone=3Dffff8801005fee00
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 kswapd0 =C2=A0 =C2=A047 [000] 59599.956606: =
shrink_zone_return:
>> (ffffffff810c848c <- ffffffff810c96c6) arg1=3D0
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 kswapd0 =C2=A0 =C2=A047 [000] 59599.956608: =
i915_gem_inactive_shrink:
>> (ffffffffa0081e48) gfp_mask=3Dd0 nr_to_scan=3D0
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 kswapd0 =C2=A0 =C2=A047 [000] 59599.956609: =
shrink_return:
>> (ffffffffa0081e48 <- ffffffff810c6a62) arg1=3D0
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 kswapd0 =C2=A0 =C2=A047 [000] 59599.956610: =
shrink_slab_return:
>> (ffffffff810c69f5 <- ffffffff810c96ec) arg1=3D0
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 kswapd0 =C2=A0 =C2=A047 [000] 59599.956611: =
mm_vmscan_kswapd_wake: nid=3D0 order=3D0
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 kswapd0 =C2=A0 =C2=A047 [000] 59599.956612: =
shrink_zone:
>> (ffffffff810c848c) priority=3D12 zone=3Dffff8801005fe000
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 kswapd0 =C2=A0 =C2=A047 [000] 59599.956614: =
shrink_zone_return:
>> (ffffffff810c848c <- ffffffff810c96c6) arg1=3D0
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 kswapd0 =C2=A0 =C2=A047 [000] 59599.956616: =
i915_gem_inactive_shrink:
>> (ffffffffa0081e48) gfp_mask=3Dd0 nr_to_scan=3D0
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 kswapd0 =C2=A0 =C2=A047 [000] 59599.956617: =
shrink_return:
>> (ffffffffa0081e48 <- ffffffff810c6a62) arg1=3D0
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 kswapd0 =C2=A0 =C2=A047 [000] 59599.956618: =
shrink_slab_return:
>> (ffffffff810c69f5 <- ffffffff810c96ec) arg1=3D0
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 kswapd0 =C2=A0 =C2=A047 [000] 59599.956620: =
i915_gem_inactive_shrink:
>> (ffffffffa0081e48) gfp_mask=3Dd0 nr_to_scan=3D0
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 kswapd0 =C2=A0 =C2=A047 [000] 59599.956621: =
shrink_return:
>> (ffffffffa0081e48 <- ffffffff810c6a62) arg1=3D0
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 kswapd0 =C2=A0 =C2=A047 [000] 59599.956621: =
shrink_slab_return:
>> (ffffffff810c69f5 <- ffffffff810c96ec) arg1=3D0
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 kswapd0 =C2=A0 =C2=A047 [000] 59599.956623: =
shrink_zone:
>> (ffffffff810c848c) priority=3D12 zone=3Dffff8801005fee00
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 kswapd0 =C2=A0 =C2=A047 [000] 59599.956624: =
shrink_zone_return:
>> (ffffffff810c848c <- ffffffff810c96c6) arg1=3D0
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 kswapd0 =C2=A0 =C2=A047 [000] 59599.956626: =
i915_gem_inactive_shrink:
>> (ffffffffa0081e48) gfp_mask=3Dd0 nr_to_scan=3D0
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 kswapd0 =C2=A0 =C2=A047 [000] 59599.956627: =
shrink_return:
>> (ffffffffa0081e48 <- ffffffff810c6a62) arg1=3D0
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 kswapd0 =C2=A0 =C2=A047 [000] 59599.956628: =
shrink_slab_return:
>> (ffffffff810c69f5 <- ffffffff810c96ec) arg1=3D0
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 kswapd0 =C2=A0 =C2=A047 [000] 59599.956629: =
mm_vmscan_kswapd_wake: nid=3D0 order=3D0
>>
>> The command was:
>>
>> perf record -g -aR -p 47 -e probe:i915_gem_inactive_shrink -e
>> probe:shrink_return -e probe:shrink_slab_return -e probe:shrink_zone
>> -e probe:shrink_zone_return -e probe:kswapd_try_to_sleep -e
>> vmscan:mm_vmscan_kswapd_sleep -e vmscan:mm_vmscan_kswapd_wake -e
>> vmscan:mm_vmscan_wakeup_kswapd -e vmscan:mm_vmscan_lru_shrink_inactive
>> -e probe:wakeup_kswapd; perf script
>>
>> (shrink_return is i915_gem_inactive_shrink's return. =C2=A0sorry, badly =
named.)
>>
>> It looks like something kswapd_try_to_sleep is not getting called.
>>
>> I do not know how to reproduce this, but I'll leave it running overnight=
.

If the problem happen again, could you probe wakeup_kswapd, too?
I think it can help us.

Thanks.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
