From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH v2] Linux VM workaround for Knights Landing A/D leak
Date: Tue, 14 Jun 2016 13:20:06 -0700
Message-ID: <4b2c481e-35ae-1cd6-ca58-1535bfef346c@zytor.com>
References: <7FB15233-B347-4A87-9506-A9E10D331292@gmail.com>
 <1465923672-14232-1-git-send-email-lukasz.anaczkowski@intel.com>
 <57603DC0.9070607@linux.intel.com>
 <20160614193407.1470d998@lxorguk.ukuu.org.uk>
 <576052E0.3050408@linux.intel.com> <20160614191916.GI30015@pd.tnic>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160614191916.GI30015@pd.tnic>
Sender: linux-kernel-owner@vger.kernel.org
To: Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>
Cc: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, Lukasz Anaczkowski <lukasz.anaczkowski@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, ak@linux.intel.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, akpm@linux-foundation.org, harish.srinivasappa@intel.com, lukasz.odzioba@intel.com, grzegorz.andrejczuk@intel.com, lukasz.daniluk@intel.com
List-Id: linux-mm.kvack.org

On 06/14/16 12:19, Borislav Petkov wrote:
> On Tue, Jun 14, 2016 at 11:54:24AM -0700, Dave Hansen wrote:
>> Lukasz, Borislav suggested using static_cpu_has_bug(), which will do the
>> alternatives patching.  It's definitely the right thing to use here.
> 
> Yeah, either that or do an
> 
> alternative_call(null_func, fix_pte_peak, X86_BUG_PTE_LEAK, ...)
> 
> or so and you'll need a dummy function to call on !X86_BUG_PTE_LEAK
> CPUs.
> 
> The static_cpu_has_bug() thing should be most likely a penalty
> of a single JMP (I have to look at the asm) but then since the
> callers are inlined, you'll have to patch all those places where
> *ptep_get_and_clear() get inlined.
> 
> Shouldn't be a big deal still but...
> 
> "debug-alternative" and a kvm guest should help you there to get a quick
> idea.
> 

static_cpu_has_bug() should turn into 5-byte NOP in the common (bugless)
case.

	-hpa
