Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 266BD8D0040
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 12:52:41 -0400 (EDT)
Message-ID: <4D8A2517.3090403@fiec.espol.edu.ec>
Date: Wed, 23 Mar 2011 11:51:35 -0500
From: =?ISO-8859-1?Q?Alex_Villac=ED=ADs_Lasso?=
 <avillaci@fiec.espol.edu.ec>
MIME-Version: 1.0
Subject: Re: [Bugme-new] [Bug 31142] New: Large write to USB stick freezes
 unrelated tasks for a long time
References: <20110319235144.GG10696@random.random> <20110321094149.GH707@csn.ul.ie> <20110321134832.GC5719@random.random> <20110321163742.GA24244@csn.ul.ie> <4D878564.6080608@fiec.espol.edu.ec> <20110321201641.GA5698@random.random> <20110322112032.GD24244@csn.ul.ie> <20110322150314.GC5698@random.random> <4D8907C2.7010304@fiec.espol.edu.ec> <20110322214020.GD5698@random.random> <20110323003718.GH5698@random.random>
In-Reply-To: <20110323003718.GH5698@random.random>
Content-Type: multipart/alternative;
 boundary="------------060505060109000608090406"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, avillaci@ceibo.fiec.espol.edu.ec, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org

This is a multi-part message in MIME format.
--------------060505060109000608090406
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

El 22/03/11 19:37, Andrea Arcangeli escribio:
> Hi Alex,
>
> could you also try to reverse this below bit (not the whole previous
> patch: only the bit below quoted below) with "patch -p1 -R<  thismail"
> on top of your current aa.git tree, and see if you notice any
> regression compared to the previous aa.git build that worked well?
>
> This is part of the fix, but I'd need to be sure this really makes a
> difference before sticking to it for long. I'm not concerned by
> keeping it, but it adds dirt, and the closer THP allocations are to
> any other high order allocation the better. So the less
> __GFP_NO_KSWAPD affects the better. The hint about not telling kswapd
> to insist in the background for order 9 allocations with fallback
> (like THP) is the maximum I consider clean because there's khugepaged
> with its alloc_sleep_millisecs that replaces the kswapd task for THP
> allocations. So that is clean enough, but when __GFP_NO_KSWAPD starts
> to make compaction behave slightly different from a SLUB order 2
> allocation I don't like it (especially because if you later enable
> SLUB or some driver you may run into the same compaction issue again
> if the below change is making a difference).
>
> If things works fine even after you reverse the below, we can safely
> undo this change and also feel safer for all other high order
> allocations, so it'll make life easier. (plus we don't want
> unnecessary special changes, we need to be sure this makes a
> difference to keep it for long)
>
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2085,7 +2085,7 @@ rebalance:
>   					sync_migration);
>   	if (page)
>   		goto got_pg;
> -	sync_migration = true;
> +	sync_migration = !(gfp_mask&  __GFP_NO_KSWAPD);
>
>   	/* Try direct reclaim and then allocating */
>   	page = __alloc_pages_direct_reclaim(gfp_mask, order,
>

> On Tue, Mar 22, 2011 at 03:34:10PM -0500, Alex Villaci-s Lasso wrote:
>> >  I have just tested aa.git as of today, with the USB stick formatted
>> >  as FAT32. I could no longer reproduce the stall
> Probably udf is not optimized enough but I wonder if maybe the
> udf->vfat change helped more than the other patches. We need the other
> patches anyway to provide responsive behavior including the one you
> tested before aa.git so it's not very important if udf was the
> problem, but it might have been.
>
I tried to reformat the stick as UDF to check whether the stall was filesystem-sensitive. Apparently it is. I managed to induce the freeze on firefox while performing the same copy on the aa.git kernel. Then I reformatted the stick as FAT32 and repeated 
the test, and it also induced freezes, although they were a bit shorter and occurred late in the copy progress. I have attached the traces in the bug report. All of this is with the kernel before reversing the quoted patch.

--------------060505060109000608090406
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <meta content="text/html; charset=ISO-8859-1"
      http-equiv="Content-Type">
  </head>
  <body bgcolor="#ffffff" text="#000000">
    El 22/03/11 19:37, Andrea Arcangeli escribi&oacute;:
    <blockquote cite="mid:20110323003718.GH5698@random.random"
      type="cite">
      <pre wrap="">Hi Alex,

could you also try to reverse this below bit (not the whole previous
patch: only the bit below quoted below) with "patch -p1 -R &lt; thismail"
on top of your current aa.git tree, and see if you notice any
regression compared to the previous aa.git build that worked well?

This is part of the fix, but I'd need to be sure this really makes a
difference before sticking to it for long. I'm not concerned by
keeping it, but it adds dirt, and the closer THP allocations are to
any other high order allocation the better. So the less
__GFP_NO_KSWAPD affects the better. The hint about not telling kswapd
to insist in the background for order 9 allocations with fallback
(like THP) is the maximum I consider clean because there's khugepaged
with its alloc_sleep_millisecs that replaces the kswapd task for THP
allocations. So that is clean enough, but when __GFP_NO_KSWAPD starts
to make compaction behave slightly different from a SLUB order 2
allocation I don't like it (especially because if you later enable
SLUB or some driver you may run into the same compaction issue again
if the below change is making a difference).

If things works fine even after you reverse the below, we can safely
undo this change and also feel safer for all other high order
allocations, so it'll make life easier. (plus we don't want
unnecessary special changes, we need to be sure this makes a
difference to keep it for long)

--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2085,7 +2085,7 @@ rebalance:
 					sync_migration);
 	if (page)
 		goto got_pg;
-	sync_migration = true;
+	sync_migration = !(gfp_mask &amp; __GFP_NO_KSWAPD);
 
 	/* Try direct reclaim and then allocating */
 	page = __alloc_pages_direct_reclaim(gfp_mask, order,

</pre>
    </blockquote>
    <br>
    <blockquote type="cite">
      <div class="moz-text-plain" wrap="true" style="font-family:
        -moz-fixed; font-size: 14px;" lang="x-western">
        <pre wrap="">On Tue, Mar 22, 2011 at 03:34:10PM -0500, Alex Villac&iacute;&shy;s Lasso wrote:
</pre>
        <blockquote type="cite" style="color: rgb(0, 0, 0);">
          <pre wrap=""><span class="moz-txt-citetags">&gt; </span>I have just tested aa.git as of today, with the USB stick formatted
<span class="moz-txt-citetags">&gt; </span>as FAT32. I could no longer reproduce the stall
</pre>
        </blockquote>
        <pre wrap="">Probably udf is not optimized enough but I wonder if maybe the
udf-&gt;vfat change helped more than the other patches. We need the other
patches anyway to provide responsive behavior including the one you
tested before aa.git so it's not very important if udf was the
problem, but it might have been.

</pre>
      </div>
    </blockquote>
    I tried to reformat the stick as UDF to check whether the stall was
    filesystem-sensitive. Apparently it is. I managed to induce the
    freeze on firefox while performing the same copy on the aa.git
    kernel. Then I reformatted the stick as FAT32 and repeated the test,
    and it also induced freezes, although they were a bit shorter and
    occurred late in the copy progress. I have attached the traces in
    the bug report. All of this is with the kernel before reversing the
    quoted patch.
  </body>
</html>

--------------060505060109000608090406--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
