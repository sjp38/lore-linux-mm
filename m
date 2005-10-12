From: Mark Nutter <mnutter@us.ibm.com>
Subject: Re: ppc64/cell: local TLB flush with active SPEs
Date: Wed, 12 Oct 2005 17:09:26 -0500
Message-ID: <OF66519BDB.81F21C74-ON85257098.0078C43D-86257098.0079BEBE@us.ibm.com>
References: <200510122003.59701.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1857875709=="
Return-path: <linuxppc64-dev-bounces@ozlabs.org>
In-Reply-To: <200510122003.59701.arnd@arndb.de>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc64-dev>
List-Post: <mailto:linuxppc64-dev@ozlabs.org>
List-Help: <mailto:linuxppc64-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=subscribe>
Mime-version: 1.0
Sender: linuxppc64-dev-bounces@ozlabs.org
Errors-To: linuxppc64-dev-bounces@ozlabs.org
To: Arnd Bergmann <arnd@arndb.de>
Cc: linux-mm@kvack.org, Ulrich Weigand <Ulrich.Weigand@de.ibm.com>, Paul Mackerras <paulus@samba.org>, Max Aguilar <maguilar@us.ibm.com>, linuxppc64-dev@ozlabs.org, Michael Day <mnday@us.ibm.com>
List-Id: linux-mm.kvack.org

This is a multipart message in MIME format.
--===============1857875709==
Content-Type: multipart/alternative;
	boundary="=_alternative 0079BEBB86257098_="

This is a multipart message in MIME format.
--=_alternative 0079BEBB86257098_=
Content-Type: text/plain; charset="US-ASCII"

For reference, the 2.6.3 bring-up kernel always issued global TLBIE.  This 
was a hack, and we very much wanted to improve performance if possible, 
particularly for the vast majority of PPC applications out there that 
don't use SPEs.

As long as we are thinking about a proper solution, the whole 
mm->cpu_vm_mask thing is broken, at least as a selector for local -vs- 
global TLBIE.  The problem, as I see it, is that memory regions can shared 
among processes (via mmap/shmat), with each task bound to different 
processors.  If we are to continue using a cpumask as selector for TLBIE, 
then we really need a vma->cpu_vma_mask. 
 
---
Mark Nutter
STI Design Center / IBM
email: mnutter@us.ibm.com
voice: 512-838-1612
fax: 512-838-1927
11400 Burnet Road
Mail Stop 906/3003B
Austin, TX 78758





Arnd Bergmann <arnd@arndb.de>
10/12/2005 01:03 PM
 
        To:     linuxppc64-dev@ozlabs.org, linux-mm@kvack.org
        cc:     Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul 
Mackerras <paulus@samba.org>, Mark Nutter/Austin/IBM@IBMUS, Michael 
Day/Austin/IBM@IBMUS, Ulrich Weigand <Ulrich.Weigand@de.ibm.com>
        Subject:        ppc64/cell: local TLB flush with active SPEs


I'm looking for a clean solution to detect the need for global
TLB flush when an mm_struct is only used on one logical PowerPC
CPU (PPE) and also mapped with the memory flow controller of an
SPE on the Cell CPU.

Normally, we set bits in mm_struct:cpu_vm_mask for each CPU that
accesses the mm and then do global flushes instead of local flushes
when CPUs other than the currently running one are marked as used
in that mask. When an SPE does DMA to that mm, it also gets local
TLB entries that are only flushed with a global tlbie broadcast.

The current hack is to always set cpu_vm_mask to all bits set
when we map an mm into an SPE to ensure receiving the broadcast,
but that is obviously not how it's meant to be used. In particular,
it doesn't work in UP configurations where the cpumask contains
only one bit.

One solution that might be better could be to introduce a new special
flag in addition to cpu_vm_mask for this purpose. We already have
a bit field in mm_struct for dumpable, so adding another bit there
at least does not waste space for other platforms, and it's likely
to be in the same cache line as cpu_vm_mask. However, I'm reluctant
to add more bit fields to such a prominent place, because it might
encourage other people to add more bit fields or thing that they
are accepted coding practice.

Another idea would be to add a new field to mm_context_t, so it stays
in the architecture specific code. Again, adding an int here does
not waste space because there is currently padding in that place on
ppc64.

Or maybe there is a completely different solution.

Suggestions?

                 Arnd <><


--=_alternative 0079BEBB86257098_=
Content-Type: text/html; charset="US-ASCII"


<br><font size=2 face="sans-serif">For reference, the 2.6.3 bring-up kernel
always issued global TLBIE. &nbsp;This was a hack, and we very much wanted
to improve performance if possible, particularly for the vast majority
of PPC applications out there that don't use SPEs.</font>
<br>
<br><font size=2 face="sans-serif">As long as we are thinking about a proper
solution, the whole mm-&gt;cpu_vm_mask thing is broken, at least as a selector
for local -vs- global TLBIE. &nbsp;The problem, as I see it, is that memory
regions can shared among processes (via mmap/shmat), with each task bound
to different processors. &nbsp;If we are to continue using a cpumask as
selector for TLBIE, then we really need a vma-&gt;cpu_vma_mask. </font>
<br><font size=2 face="sans-serif">&nbsp;</font>
<br><font size=2 face="sans-serif">---<br>
Mark Nutter<br>
STI Design Center / IBM<br>
email: mnutter@us.ibm.com<br>
voice: 512-838-1612<br>
fax: 512-838-1927<br>
11400 Burnet Road<br>
Mail Stop 906/3003B<br>
Austin, TX 78758<br>
</font>
<br>
<br>
<br>
<table width=100%>
<tr valign=top>
<td>
<td><font size=1 face="sans-serif"><b>Arnd Bergmann &lt;arnd@arndb.de&gt;</b></font>
<p><font size=1 face="sans-serif">10/12/2005 01:03 PM</font>
<td><font size=1 face="Arial">&nbsp; &nbsp; &nbsp; &nbsp; </font>
<br><font size=1 face="sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; To:
&nbsp; &nbsp; &nbsp; &nbsp;linuxppc64-dev@ozlabs.org, linux-mm@kvack.org</font>
<br><font size=1 face="sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; cc:
&nbsp; &nbsp; &nbsp; &nbsp;Benjamin Herrenschmidt &lt;benh@kernel.crashing.org&gt;,
Paul Mackerras &lt;paulus@samba.org&gt;, Mark Nutter/Austin/IBM@IBMUS,
Michael Day/Austin/IBM@IBMUS, Ulrich Weigand &lt;Ulrich.Weigand@de.ibm.com&gt;</font>
<br><font size=1 face="sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; Subject:
&nbsp; &nbsp; &nbsp; &nbsp;ppc64/cell: local TLB flush with active
SPEs</font></table>
<br>
<br>
<br><font size=2><tt>I'm looking for a clean solution to detect the need
for global<br>
TLB flush when an mm_struct is only used on one logical PowerPC<br>
CPU (PPE) and also mapped with the memory flow controller of an<br>
SPE on the Cell CPU.<br>
<br>
Normally, we set bits in mm_struct:cpu_vm_mask for each CPU that<br>
accesses the mm and then do global flushes instead of local flushes<br>
when CPUs other than the currently running one are marked as used<br>
in that mask. When an SPE does DMA to that mm, it also gets local<br>
TLB entries that are only flushed with a global tlbie broadcast.<br>
<br>
The current hack is to always set cpu_vm_mask to all bits set<br>
when we map an mm into an SPE to ensure receiving the broadcast,<br>
but that is obviously not how it's meant to be used. In particular,<br>
it doesn't work in UP configurations where the cpumask contains<br>
only one bit.<br>
<br>
One solution that might be better could be to introduce a new special<br>
flag in addition to cpu_vm_mask for this purpose. We already have<br>
a bit field in mm_struct for dumpable, so adding another bit there<br>
at least does not waste space for other platforms, and it's likely<br>
to be in the same cache line as cpu_vm_mask. However, I'm reluctant<br>
to add more bit fields to such a prominent place, because it might<br>
encourage other people to add more bit fields or thing that they<br>
are accepted coding practice.<br>
<br>
Another idea would be to add a new field to mm_context_t, so it stays<br>
in the architecture specific code. Again, adding an int here does<br>
not waste space because there is currently padding in that place on<br>
ppc64.<br>
<br>
Or maybe there is a completely different solution.<br>
<br>
Suggestions?<br>
<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
Arnd &lt;&gt;&lt;<br>
</tt></font>
<br>
--=_alternative 0079BEBB86257098_=--

--===============1857875709==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc64-dev mailing list
Linuxppc64-dev@ozlabs.org
https://ozlabs.org/mailman/listinfo/linuxppc64-dev

--===============1857875709==--
