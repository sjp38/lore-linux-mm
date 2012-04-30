Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 914BA6B0044
	for <linux-mm@kvack.org>; Mon, 30 Apr 2012 16:33:01 -0400 (EDT)
Received: by yenm8 with SMTP id m8so2242913yen.14
        for <linux-mm@kvack.org>; Mon, 30 Apr 2012 13:33:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120430104850.11118.58938.stgit@zurg>
References: <4F91BC8A.9020503@parallels.com> <20120430104850.11118.58938.stgit@zurg>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Mon, 30 Apr 2012 16:32:40 -0400
Message-ID: <CAHGf_=qouwZZa-6szhFxe0-yQZO54SaJC_bqh6iNj8zwnrpcyg@mail.gmail.com>
Subject: Re: [PATCH v3] proc: report file/anon bit in /proc/pid/pagemap
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Pavel Emelyanov <xemul@parallels.com>, Hugh Dickins <hughd@google.com>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Apr 30, 2012 at 6:48 AM, Konstantin Khlebnikov
<khlebnikov@openvz.org> wrote:
> This is an implementation of Andrew's proposal to extend the pagemap file
> bits to report what is missing about tasks' working set.
>
> The problem with the working set detection is multilateral. In the criu
> (checkpoint/restore) project we dump the tasks' memory into image files
> and to do it properly we need to detect which pages inside mappings are
> really in use. The mincore syscall I though could help with this did not.
> First, it doesn't report swapped pages, thus we cannot find out which
> parts of anonymous mappings to dump. Next, it does report pages from page
> cache as present even if they are not mapped, and it doesn't make
> difference between private pages that has been cow-ed and private pages
> that has not been cow-ed.
>
> Note, that issue with swap pages is critical -- we must dump swap pages t=
o
> image file. But the issues with file pages are optimization -- we can tak=
e
> all file pages to image, this would be correct, but if we know that a pag=
e
> is not mapped or not cow-ed, we can remove them from dump file. The dump
> would still be self-consistent, though significantly smaller in size (up
> to 10 times smaller on real apps).
>
> Andrew noticed, that the proc pagemap file solved 2 of 3 above issues -- =
it
> reports whether a page is present or swapped and it doesn't report not
> mapped page cache pages. But, it doesn't distinguish cow-ed file pages fr=
om
> not cow-ed.
>
> I would like to make the last unused bit in this file to report whether t=
he
> page mapped into respective pte is PageAnon or not.
>
> [comment stolen from Pavel Emelyanov's v1 patch]
>
> v2:
> * Rebase to uptodate kernel
> * Fix file/anon bit reporting for migration entries
> * Fix frame bits interval comment, it uses 55 lower bits (64 - 3 - 6)
>
> v3:
> * fix stupid misprint s/if/else if/
> * rebase on top of "[PATCH bugfix] proc/pagemap: correctly report non-pre=
sent
> =A0ptes and holes between vmas"
> * second patch (with indexes for nonlinear mappings) was droppped.
>
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> Cc: Pavel Emelyanov <xemul@parallels.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Matt Mackall <mpm@selenic.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>

I don't like an exporting naive kernel internal. But unfortunately I
have no alternative idea..
 Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
