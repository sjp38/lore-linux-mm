Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 1A73C6B0032
	for <linux-mm@kvack.org>; Tue,  2 Jul 2013 06:15:11 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id hq4so4033955wib.6
        for <linux-mm@kvack.org>; Tue, 02 Jul 2013 03:15:09 -0700 (PDT)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
In-Reply-To: <20130630181945.GA5171@redhat.com>
References: <CA+icZUXo=Z4gDfCMvLqRQDq_fpNAq+UqtUw=jrU=3=kVZP-2+A@mail.gmail.com>
	<20130630181945.GA5171@redhat.com>
Date: Tue, 2 Jul 2013 12:15:09 +0200
Message-ID: <CA+icZUWLUSg-Sfd9FHXs8Amz+-s6vs_VOJsQpUSa9+fYM8XyNQ@mail.gmail.com>
Subject: Re: linux-next: Tree for Jun 28 [ BISECTED: rsyslog/imklog: High CPU
 usage ]
From: Sedat Dilek <sedat.dilek@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Daniel Vetter <daniel.vetter@ffwll.ch>, Imre Deak <imre.deak@intel.com>, Lukas Czerner <lczerner@redhat.com>, Samuel Ortiz <samuel@sortiz.org>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Ralf Baechle <ralf@linux-mips.org>, Valdis.Kletnieks@vt.edu, linux-mm <linux-mm@kvack.org>

On Sun, Jun 30, 2013 at 8:19 PM, Oleg Nesterov <oleg@redhat.com> wrote:
> Andrew, please drop these
>
>         wait-introduce-wait_event_commonwq-condition-state-timeout.patch
>         wait-introduce-prepare_to_wait_event.patch
>
> patches again. I'll send v3 although it really looks like I should
> never try to touch wait.h.
>
> On 06/29, Sedat Dilek wrote:
>>
>> As this all did not show me what caused the problem I started a
>> git-bisect session.
>>
>> This revealed the following culprit commit:
>>
>>      commit bb1f30cb7d3ba21098f0ee7e0382160ba2599a43
>>      "wait: introduce wait_event_common(wq, condition, state, timeout)"
>
> Heh. First of all, I am really sorry.
>
> Not only "__wait_no_timeout(tout) ?:" was wrong, I didn't bother
> to recheck this logic even after I got the "warning: the omitted
> middle operand in ?:" reports.
>
> Sedat, thanks you very much! Any chance you can try the patch below?
>

[ CC linux-mm ML ]

Hi Oleg,

did you made a cleaned-up version?
AFAICS v3, I read that on linux-mm ML, sorry if I ask here in this thread.

Regards,
- Sedat -

> Oleg.
>
>
> --- a/include/linux/wait.h
> +++ b/include/linux/wait.h
> @@ -191,12 +191,8 @@ wait_queue_head_t *bit_waitqueue(void *, int);
>         for (;;) {                                                      \
>                 __ret = prepare_to_wait_event(&wq, &__wait, state);     \
>                 if (condition) {                                        \
> -                       __ret = __wait_no_timeout(tout);                \
> -                       if (!__ret) {                                   \
> -                               __ret = __tout;                         \
> -                               if (!__ret)                             \
> -                                       __ret = 1;                      \
> -                       }                                               \
> +                       __ret = __wait_no_timeout(tout) ? 0 :           \
> +                                                       (__tout ?: 1);  \
>                         break;                                          \
>                 }                                                       \
>                                                                         \
> @@ -217,16 +213,10 @@ wait_queue_head_t *bit_waitqueue(void *, int);
>  #define wait_event_common(wq, condition, state, tout)                  \
>  ({                                                                     \
>         long __ret;                                                     \
> -       if (condition) {                                                \
> -               __ret = __wait_no_timeout(tout);                        \
> -               if (!__ret) {                                           \
> -                       __ret = tout;                                   \
> -                       if (!__ret)                                     \
> -                               __ret = 1;                              \
> -               }                                                       \
> -       } else {                                                        \
> +       if (condition)                                                  \
> +               __ret = __wait_no_timeout(tout) ? 0 : ((tout) ?: 1);    \
> +       else                                                            \
>                 __ret = __wait_event_common(wq, condition, state, tout);\
> -       }                                                               \
>         __ret;                                                          \
>  })
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
