Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 4DCE96B0254
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 07:42:04 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id p65so16047487wmp.0
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 04:42:04 -0800 (PST)
Date: Fri, 11 Mar 2016 13:42:01 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 04/18] mm, aout: handle vm_brk failures
Message-ID: <20160311124201.GK27701@dhcp22.suse.cz>
References: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
 <1456752417-9626-5-git-send-email-mhocko@kernel.org>
 <56E29ECA.5050809@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56E29ECA.5050809@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Deucher <alexander.deucher@amd.com>, Alex Thorlton <athorlton@sgi.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, Benjamin LaHaise <bcrl@kvack.org>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, Daniel Vetter <daniel.vetter@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Airlie <airlied@linux.ie>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, "H . Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-arch@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Petr Cermak <petrcermak@chromium.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>

On Fri 11-03-16 11:32:42, Vlastimil Babka wrote:
> On 02/29/2016 02:26 PM, Michal Hocko wrote:
> >From: Michal Hocko <mhocko@suse.com>
> >
> >vm_brk is allowed to fail but load_aout_binary simply ignores the error
> >and happily continues. I haven't noticed any problem from that in real
> >life but later patches will make the failure more likely because
> >vm_brk will become killable (resp. mmap_sem for write waiting will become
> >killable) so we should be more careful now.
> >
> >The error handling should be quite straightforward because there are
> >calls to vm_mmap which check the error properly already. The only
> >notable exception is set_brk which is called after beyond_if label.
> >But nothing indicates that we cannot move it above set_binfmt as the two
> >do not depend on each other and fail before we do set_binfmt and alter
> >reference counting.
> >
> >Cc: Thomas Gleixner <tglx@linutronix.de>
> >Cc: Ingo Molnar <mingo@redhat.com>
> >Cc: "H. Peter Anvin" <hpa@zytor.com>
> >Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> >Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> Acked--by: Vlastimil Babka <vbabka@suse.cz>

thanks!
> 
> [...]
> 
> >@@ -378,7 +381,9 @@ static int load_aout_library(struct file *file)
> >  			       "N_TXTOFF is not page aligned. Please convert library: %pD\n",
> >  			       file);
> >  		}
> >-		vm_brk(start_addr, ex.a_text + ex.a_data + ex.a_bss);
> >+		retval = vm_brk(start_addr, ex.a_text + ex.a_data + ex.a_bss);
> >+		if (IS_ERR_VALUE(retval))
> >+			goto out;
> >  		
> 
> You could have removed the extra whitespace on the line above, which my vim
> so prominently highlights :)

Fixed

> 
> >  		read_code(file, start_addr, N_TXTOFF(ex),
> >  			  ex.a_text + ex.a_data);
> >

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
