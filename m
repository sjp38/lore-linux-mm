From: "Fredrik Klasson" <scientica@gmail.com>
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge
	plans for 2.6.23]
Date: Thu, 26 Jul 2007 15:05:16 +0200
Message-ID: <6242fec60707260605h27eeb94bm522e01bd749f347c@mail.gmail.com>
References: <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>
	<2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>
	<46A58B49.3050508@yahoo.com.au>
	<2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>
	<46A6CC56.6040307@yahoo.com.au> <p73abtkrz37.fsf@bingen.suse.de>
	<46A85D95.509@kingswood-consulting.co.uk>
	<20070726092025.GA9157@elte.hu>
	<20070726023401.f6a2fbdf.akpm@linux-foundation.org>
	<20070726094024.GA15583@elte.hu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============26753880934329843=="
Return-path: <ck-bounces@vds.kolivas.org>
In-Reply-To: <20070726094024.GA15583@elte.hu>
List-Unsubscribe: <http://bhhdoa.org.au/mailman/listinfo/ck>,
	<mailto:ck-request@vds.kolivas.org?subject=unsubscribe>
List-Archive: <http://bhhdoa.org.au/pipermail/ck>
List-Post: <mailto:ck@vds.kolivas.org>
List-Help: <mailto:ck-request@vds.kolivas.org?subject=help>
List-Subscribe: <http://bhhdoa.org.au/mailman/listinfo/ck>,
	<mailto:ck-request@vds.kolivas.org?subject=subscribe>
Sender: ck-bounces@vds.kolivas.org
Errors-To: ck-bounces@vds.kolivas.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, linux-kernel@vger.kernel.org, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org, Paul Jackson <pj@sgi.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Frank Kingswood <frank@kingswood-consulting.co.uk>
List-Id: linux-mm.kvack.org

--===============26753880934329843==
Content-Type: multipart/alternative;
	boundary="----=_Part_195262_15966373.1185455116504"

------=_Part_195262_15966373.1185455116504
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On 7/26/07, Ingo Molnar <mingo@elte.hu> wrote:
>
> --- /etc/cron.daily/mlocate.cron.orig
> +++ /etc/cron.daily/mlocate.cron
> @@ -1,4 +1,7 @@
> #!/bin/sh
> nodevs=$(< /proc/filesystems awk '$1 == "nodev" { print $2 }')
> renice +19 -p $$ >/dev/null 2>&1
> +PREV=`cat /proc/sys/vm/vfs_cache_pressure 2>/dev/null`
> +echo 0 > /proc/sys/vm/vfs_cache_pressure 2>/dev/null
> /usr/bin/updatedb -f "$nodevs"
> +[ "$PREV" != "" ] && echo $PREV > /proc/sys/vm/vfs_cache_pressure
> 2>/dev/null
> _______________________________________________
> http://ck.kolivas.org/faqs/replying-to-mailing-list.txt
> ck mailing list - mailto: ck@vds.kolivas.org
> http://vds.kolivas.org/mailman/listinfo/ck


uhm... pardon my ignorance, but, doesn't this hack create a possible race
condition?
Ie, this job starts, and while updatedb runs some other app/script (let's
call it Gort) pokes with vfs_cache_pressure (saving 10000, as it's the
current value), then updatedb finishes, and then a while after that Gort
stops, "restoring" vfs_cache_pressure to 10000 instead of $PREV?

What we _really_ want is an updatedb that
> does not disturb the dcache.
>
just a thought, the problem seems (to me, a mere mortal at best) to be that
the functions/program doing the magic messes up caches. Wouldn't the
easiest/obvious solution/hack be to use/write an "uncached_" version of
those functions/apps? (or one that just reads the cache, but never upsets it
by writing to it). Or is that impossible/impractical for some reason? (or
worse yet, have I completely missed the point?)

-- 
... a professor saying: "use this proprietary software to learn computer
science" is the same as English professor handing you a copy of Shakespeare
and saying: "use this book to learn Shakespeare without opening the book
itself.
- Bradley Kuhn

------=_Part_195262_15966373.1185455116504
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

<br><br><div><span class="gmail_quote">On 7/26/07, <b class="gmail_sendername">Ingo Molnar</b> &lt;<a href="mailto:mingo@elte.hu">mingo@elte.hu</a>&gt; wrote:</span><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">
--- /etc/cron.daily/mlocate.cron.orig<br>+++ /etc/cron.daily/mlocate.cron<br>@@ -1,4 +1,7 @@<br> #!/bin/sh<br> nodevs=$(&lt; /proc/filesystems awk &#39;$1 == &quot;nodev&quot; { print $2 }&#39;)<br> renice +19 -p $$ &gt;/dev/null 2&gt;&amp;1
<br>+PREV=`cat /proc/sys/vm/vfs_cache_pressure 2&gt;/dev/null`<br>+echo 0 &gt; /proc/sys/vm/vfs_cache_pressure 2&gt;/dev/null<br> /usr/bin/updatedb -f &quot;$nodevs&quot;<br>+[ &quot;$PREV&quot; != &quot;&quot; ] &amp;&amp; echo $PREV &gt; /proc/sys/vm/vfs_cache_pressure 2&gt;/dev/null
<br>_______________________________________________<br><a href="http://ck.kolivas.org/faqs/replying-to-mailing-list.txt">http://ck.kolivas.org/faqs/replying-to-mailing-list.txt</a><br>ck mailing list - mailto: <a href="mailto:ck@vds.kolivas.org">
ck@vds.kolivas.org</a><br><a href="http://vds.kolivas.org/mailman/listinfo/ck">http://vds.kolivas.org/mailman/listinfo/ck</a></blockquote><div>&nbsp;</div>uhm... pardon my ignorance, but, doesn&#39;t this hack create a possible race condition?
<br></div>Ie, this job starts, and while updatedb runs some other app/script (let&#39;s call it Gort) pokes with vfs_cache_pressure (saving 10000, as it&#39;s the current value), then updatedb finishes, and then a while after that Gort stops, &quot;restoring&quot; vfs_cache_pressure to 10000 instead of $PREV?
<br><br><blockquote style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;" class="gmail_quote">What we _really_ want is an updatedb that<br>does not disturb the dcache.<br clear="all">
</blockquote>just a thought, the problem seems (to me, a mere mortal at best) to be that the functions/program doing the magic messes up caches. Wouldn&#39;t the easiest/obvious solution/hack be to use/write an &quot;uncached_&quot; version of those functions/apps? (or one that just reads the cache, but never upsets it by writing to it). Or is that impossible/impractical for some reason? (or worse yet, have I completely missed the point?)
<br><br>-- <br>... a professor saying: &quot;use this proprietary software to learn computer science&quot; is the same as English professor handing you a copy of Shakespeare and saying: &quot;use this book to learn Shakespeare without opening the book itself.
<br>- Bradley Kuhn

------=_Part_195262_15966373.1185455116504--

--===============26753880934329843==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============26753880934329843==--
