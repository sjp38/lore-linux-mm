From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: Re: [PATCH 9/9] mm: SLUB hardened usercopy support
Date: Sat, 09 Jul 2016 15:58:20 +1000
Message-ID: <40521.8543754474$1468043925@news.gmane.org>
References: <577f7e55.4668420a.84f17.5cb9SMTPIN_ADDED_MISSING@mx.google.com> <alpine.DEB.2.20.1607080844370.3379@east.gentwo.org> <CAGXu5jKE=h32tHVLsDeaPN1GfC+BB3YbFvC+5TE5TK1oR-xU3A@mail.gmail.com> <alpine.DEB.2.20.1607081119170.6192@east.gentwo.org> <CAGXu5j+UdkQA+k39GNLe5CwBPVD5ZbRGTCQLqS8VF=kWx+PtsQ@mail.gmail.com> <CAGXu5jKxw3RxWNKLX4XVCwJ6x_zA=_RwiU9jLDm2+VRO79G7+w@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <kernel-hardening-return-3864-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAGXu5jKxw3RxWNKLX4XVCwJ6x_zA=_RwiU9jLDm2+VRO79G7+w@mail.gmail.com>
To: Kees Cook <keescook@chromium.org>, Christoph Lameter <cl@linux.com>
Cc: "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Jan Kara <jack@suse.cz>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Linux-MM <linux-mm@kvack.org>, sparclinux <sparclinux@vger.kernel.org>, linux-ia64@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, linux-arch <linux-arch@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, Russell King <linux@armlinux.org.uk>, PaX Team <pageexec@freemail.hu>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Fenghua Yu <fenghua.yu@intel.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Tony Luck <tony.luck@intel.com>, Andy Lutomirski <luto@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abb ott <labbott@fedoraproject.org>, Brad Spengler <spender@grsecurity.net>, Ard Biesheuvel <ard.biesh>
List-Id: linux-mm.kvack.org

Kees Cook <keescook@chromium.org> writes:

> On Fri, Jul 8, 2016 at 1:41 PM, Kees Cook <keescook@chromium.org> wrote:
>> So, as found already, the position in the usercopy check needs to be
>> bumped down by red_left_pad, which is what Michael's fix does, so I'll
>> include it in the next version.
>
> Actually, after some offline chats, I think this is better, since it
> makes sure the ptr doesn't end up somewhere weird before we start the
> calculations. This leaves the pointer as-is, but explicitly handles
> the redzone on the offset instead, with no wrapping, etc:
>
>         /* Find offset within object. */
>         offset = (ptr - page_address(page)) % s->size;
>
> +       /* Adjust for redzone and reject if within the redzone. */
> +       if (s->flags & SLAB_RED_ZONE) {
> +               if (offset < s->red_left_pad)
> +                       return s->name;
> +               offset -= s->red_left_pad;
> +       }
> +
>         /* Allow address range falling entirely within object size. */
>         if (offset <= s->object_size && n <= s->object_size - offset)
>                 return NULL;

That fixes the case for me in kstrndup(), which allows the system to boot.

I then get two hits, which may or may not be valid:

[    2.309556] usercopy: kernel memory overwrite attempt detected to d000000003510028 (kernfs_node_cache) (64 bytes)
[    2.309995] CPU: 7 PID: 2241 Comm: wait-for-root Not tainted 4.7.0-rc3-00099-g97872fc89d41 #64
[    2.310480] Call Trace:
[    2.310556] [c0000001f4773bf0] [c0000000009bdbe8] dump_stack+0xb0/0xf0 (unreliable)
[    2.311016] [c0000001f4773c30] [c00000000029cf44] __check_object_size+0x74/0x320
[    2.311472] [c0000001f4773cb0] [c00000000005d4d0] copy_from_user+0x60/0xd4
[    2.311873] [c0000001f4773cf0] [c0000000008b38f4] __get_filter+0x74/0x160
[    2.312230] [c0000001f4773d30] [c0000000008b408c] sk_attach_filter+0x2c/0xc0
[    2.312596] [c0000001f4773d60] [c000000000871c34] sock_setsockopt+0x954/0xc00
[    2.313021] [c0000001f4773dd0] [c00000000086ac44] SyS_setsockopt+0x134/0x150
[    2.313380] [c0000001f4773e30] [c000000000009260] system_call+0x38/0x108
[    2.317045] usercopy: kernel memory overwrite attempt detected to d000000003530028 (kernfs_node_cache) (64 bytes)
[    2.317297] CPU: 10 PID: 2242 Comm: wait-for-root Not tainted 4.7.0-rc3-00099-g97872fc89d41 #64
[    2.317475] Call Trace:
[    2.317511] [c0000001f471fbf0] [c0000000009bdbe8] dump_stack+0xb0/0xf0 (unreliable)
[    2.317689] [c0000001f471fc30] [c00000000029cf44] __check_object_size+0x74/0x320
[    2.317861] [c0000001f471fcb0] [c00000000005d4d0] copy_from_user+0x60/0xd4
[    2.318011] [c0000001f471fcf0] [c0000000008b38f4] __get_filter+0x74/0x160
[    2.318165] [c0000001f471fd30] [c0000000008b408c] sk_attach_filter+0x2c/0xc0
[    2.318313] [c0000001f471fd60] [c000000000871c34] sock_setsockopt+0x954/0xc00
[    2.318485] [c0000001f471fdd0] [c00000000086ac44] SyS_setsockopt+0x134/0x150
[    2.318632] [c0000001f471fe30] [c000000000009260] system_call+0x38/0x108


With:

# zgrep SLUB /proc/config.gz
CONFIG_SLUB_DEBUG=y
CONFIG_SLUB=y
CONFIG_SLUB_CPU_PARTIAL=y
CONFIG_SLUB_DEBUG_ON=y
# CONFIG_SLUB_STATS is not set

cheers
