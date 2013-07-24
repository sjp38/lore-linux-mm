Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id DA7A46B0031
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 15:40:43 -0400 (EDT)
Received: by mail-vb0-f43.google.com with SMTP id e12so6767318vbg.16
        for <linux-mm@kvack.org>; Wed, 24 Jul 2013 12:40:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130724190453.GJ8508@moon>
References: <CALCETrXYnkonpBANnUuX+aJ=B=EYFwecZO27yrqcEU8WErz9DA@mail.gmail.com>
 <20130724163734.GE24851@moon> <CALCETrVWgSMrM2ujpO092ZLQa3pWEQM4vdmHhCVUohUUcoR8AQ@mail.gmail.com>
 <20130724171728.GH8508@moon> <1374687373.7382.22.camel@dabdike>
 <CALCETrV5MD1qCQsyz4=t+QW1BJuTBYainewzDfEaXW12S91K=A@mail.gmail.com>
 <20130724181516.GI8508@moon> <CALCETrV5NojErxWOc2RpuYKE0g8FfOmKB31oDz46CRu27hmDBA@mail.gmail.com>
 <20130724185256.GA24365@moon> <51F0232D.6060306@parallels.com> <20130724190453.GJ8508@moon>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 24 Jul 2013 12:40:22 -0700
Message-ID: <CALCETrVRQBLrQBL8_Zu0VqBRkDXXr2np57-gt4T59A4jG9jMZw@mail.gmail.com>
Subject: Re: [PATCH] mm: Save soft-dirty bits on swapped pages
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Pavel Emelyanov <xemul@parallels.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>

On Wed, Jul 24, 2013 at 12:04 PM, Cyrill Gorcunov <gorcunov@gmail.com> wrote:
> On Wed, Jul 24, 2013 at 10:55:41PM +0400, Pavel Emelyanov wrote:
>> >
>> > Well, some part of information already lays in pte (such as 'file' bit,
>> > swap entries) so it looks natural i think to work on this level. but
>> > letme think if use page struct for that be more convenient...
>>
>> It hardly will be. Consider we have a page shared between two tasks,
>> then first one "touches" it and soft-dirty is put onto his PTE and,
>> subsequently, the page itself. The we go and clear sofr-dirty for the
>> 2nd task. What should we do with the soft-dirty bit on the page?
>
> Indeed, this won't help. Well then, bippidy-boppidy-boo, our
> pants are metaphorically on fire (c)

Hmm.  So there are at least three kinds of memory:

Anonymous pages: soft-dirty works
Shared file-backed pages: soft-dirty does not work
Private file-backed pages: soft-dirty works (but see below)

Perhaps another bit should be allocated to expose to userspace either
"soft-dirty", "soft-clean", or "soft-dirty unsupported"?

There's another possible issue with private file-backed pages, though:
how do you distinguish clean-and-not-cowed from cowed-but-soft-clean?
(The former will reflect changes in the underlying file, I think, but
the latter won't.)

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
