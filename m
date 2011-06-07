Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B8D706B007E
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 16:00:20 -0400 (EDT)
Message-ID: <4DEE832D.3010901@redhat.com>
Date: Tue, 07 Jun 2011 12:59:41 -0700
From: Josh Stone <jistone@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 3.0-rc2-tip 20/22] 20: perf: perf interface for uprobes
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6> <20110607130216.28590.5724.sendpatchset@localhost6.localdomain6>
In-Reply-To: <20110607130216.28590.5724.sendpatchset@localhost6.localdomain6>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>

On 06/07/2011 06:02 AM, Srikar Dronamraju wrote:
> Enhances perf probe to user space executables and libraries.
> Provides very basic support for uprobes.

Hi Srikar,

This seems to have an issue with multiple active uprobes, whereas the v3
patchset handled this fine.  I haven't tracked down the exact code
difference yet, but here's an example transcript of what I'm seeing:

# perf probe -l
  probe_zsh:main       (on /bin/zsh:0x000000000000e3f0)
  probe_zsh:zalloc     (on /bin/zsh:0x0000000000051120)
  probe_zsh:zfree      (on /bin/zsh:0x0000000000051c70)
# perf stat -e probe_zsh:main zsh -c true

 Performance counter stats for 'zsh -c true':

                 1 probe_zsh:main

       0.029387785 seconds time elapsed

# perf stat -e probe_zsh:zalloc zsh -c true

 Performance counter stats for 'zsh -c true':

               605 probe_zsh:zalloc

       0.043836002 seconds time elapsed

# perf stat -e probe_zsh:zfree zsh -c true

 Performance counter stats for 'zsh -c true':

                36 probe_zsh:zfree

       0.029445890 seconds time elapsed

# perf stat -e probe_zsh:* zsh -c true

 Performance counter stats for 'zsh -c true':

                 0 probe_zsh:zalloc
                 1 probe_zsh:main
                 0 probe_zsh:zfree

       0.030912587 seconds time elapsed

# perf stat -e probe_zsh:z* zsh -c true

 Performance counter stats for 'zsh -c true':

               605 probe_zsh:zalloc
                 0 probe_zsh:zfree

       0.043774671 seconds time elapsed


It seems like among the selected probes, only one with the lowest offset
ever gets hit.  Any ideas?

Thanks,
Josh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
