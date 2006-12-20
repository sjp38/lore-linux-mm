Received: by ug-out-1314.google.com with SMTP id s2so1951258uge
        for <linux-mm@kvack.org>; Wed, 20 Dec 2006 00:50:46 -0800 (PST)
Message-ID: <cda58cb80612200050h6def9866nf1798753da9d842d@mail.gmail.com>
Date: Wed, 20 Dec 2006 09:50:46 +0100
From: "Franck Bui-Huu" <vagabon.xyz@gmail.com>
Subject: Re: [RFC 2.6.19 1/1] fbdev,mm: hecuba/E-Ink fbdev driver v2
In-Reply-To: <45a44e480612162025n5d7c77bdkc825e94f1fb37904@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <200612111046.kBBAkV8Y029087@localhost.localdomain>
	 <457D895D.4010500@innova-card.com>
	 <45a44e480612111554j1450f35ub4d9932e5cd32d4@mail.gmail.com>
	 <cda58cb80612130038x6b81a00dv813d10726d495eda@mail.gmail.com>
	 <45a44e480612162025n5d7c77bdkc825e94f1fb37904@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jaya Kumar <jayakumar.lkml@gmail.com>
Cc: linux-fbdev-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 12/17/06, Jaya Kumar <jayakumar.lkml@gmail.com> wrote:
> Ok. I now see what you mean. In typical cases, only one path is used
> to write. Meaning an app will decide to use the mmap path or the slow
> write path and the kernel only ever reads from its pte entry (unless
> fbcon is used which is not suited for this type of display).

Even if the kernel does only reads, you can be in trouble. For
example, the kernel access (by reading) to a data A through the cache
line 1. The application access (by writing a new value) data A through
the cahe line 5. Now it's time to update your frame buffer, so the
kernel access to data A through the cache line 1 which still contains
the _stall_ value.

Note that flushing data  before the kernel access it does not solve
any problems. If the kernel is allowed to write into the frame buffer,
the kernel don't know which line stores the up to date data...

> But you
> are right that it is possible for a situation to arise where one app
> does mmap and another is doing write.

I would say that should be a safe case. Nornally the kernel takes care
to flush caches between context switches (depending on your cache
architecture). But it's only a guess, I haven't checked the code...

> My hope is that something takes
> care of flushing the data cache for me in this case. Do you recommend
> I add something to force that?

Well I'm not the right person to answer this question. I haven't
looked at how Linux handles cache consistency yet. Knowing that I can
give you only 2 recommandations:

    - disable the cache when accessing your frame buffer (kernel and
applications).

    - when mmaping your frame buffer , be sure that the virtual
address returned by
      mmap() to the application shares the same cache lines than the
ones the kernel
      is using.

Hoping it helps,
-- 
               Franck

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
